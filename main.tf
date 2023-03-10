locals {
  gw_name            = "gw_vs_${var.adc-gw.fqdn}_ssl_443"
  gw_servicetype     = "SSL"
  gw_ip              = "0.0.0.0"
  gw_port            = 0
  gw_dtls            = "OFF"
  gw_tcpprofilename  = "tcp_prof_${var.adc-base.environmentname}"
  gw_httpprofilename = "http_prof_${var.adc-base.environmentname}"
  gw_sslprofilename  = "ssl_prof_${var.adc-base.environmentname}_fe_TLS1213"
  gw_appflowlog      = "DISABLED"
  gw_staaddresstype  = "IPV4"
}

#####
# Enable Citrix Gateway GFeature
#####

resource "citrixadc_nsfeature" "base_nsfeature" {
  sslvpn = true
}

#####
# Add Citrix GW vServer
#####
resource "citrixadc_vpnvserver" "gw_vserver" {
  name            = local.gw_name
  servicetype     = local.gw_servicetype
  ipv46           = local.gw_ip
  port            = local.gw_port
  dtls            = local.gw_dtls
  tcpprofilename  = local.gw_tcpprofilename
  httpprofilename = local.gw_httpprofilename
  appflowlog      = local.gw_appflowlog
}

#####
# Bind SSL profile to GW vServer
#####
resource "citrixadc_sslvserver" "gw_vserver_sslprofile" {
  vservername = citrixadc_vpnvserver.gw_vserver.name
  sslprofile  = local.gw_sslprofilename

  depends_on = [
    citrixadc_vpnvserver.gw_vserver
  ]
}

#####
# Bind STA Servers to GW vServer
#####
resource "citrixadc_vpnvserver_staserver_binding" "gw_vserver_staserver_binding" {
  name           = citrixadc_vpnvserver.gw_vserver.name
  staserver      = var.adc-gw.staserver
  staaddresstype = local.gw_staaddresstype

  depends_on = [
    citrixadc_vpnvserver.gw_vserver
  ]
}

#####
# Add Session Action Receiver
#####
resource "citrixadc_vpnsessionaction" "gw_sess_act_receiver" {
  name = "sess_prof_sf_receiver"
  clientlessmodeurlencoding = "TRANSPARENT"
  clientlessvpnmode = "ON"
  defaultauthorizationaction = "ALLOW"
  dnsvservername = var.adc-gw.dnsvservername
  icaproxy = "OFF"
  sesstimeout = "2880"
  sso = "ON"
  ssocredential = "PRIMARY"
  storefronturl = var.adc-gw.wihome
  transparentinterception = "OFF"
  wihome = var.adc-gw.wihome
  windowsautologon = "ON"

  depends_on = [
    citrixadc_vpnvserver.gw_vserver
  ]
}

#####
# Add Session Action Receiver Web
#####
resource "citrixadc_vpnsessionaction" "gw_sess_act_receiver_web" {
  name = "sess_prof_sf_receiver_web"
  clientchoices = "OFF"
  clientlessmodeurlencoding = "TRANSPARENT"
  clientlessvpnmode = "OFF"
  defaultauthorizationaction = "ALLOW"
  dnsvservername = var.adc-gw.dnsvservername
  icaproxy = "ON"
  locallanaccess = "ON"
  rfc1918 = "OFF"
  sesstimeout = "2880"
  sso = "ON"
  ssocredential = "PRIMARY"
  wihome = "${var.adc-gw.wihome}"
  windowsautologon = "ON"
  wiportalmode = "NORMAL"

  depends_on = [
    citrixadc_vpnvserver.gw_vserver
  ]
}

#####
# Add Session Policies
#####
resource "citrixadc_vpnsessionpolicy" "gw_sess_pol_receiver" {
  name = "sess_pol_sf_receiver"
  rule = "HTTP.REQ.HEADER(\"User-Agent\").CONTAINS(\"CitrixReceiver\") && HTTP.REQ.HEADER(\"X-Citrix-Gateway\").EXISTS"
  action = "sess_prof_sf_receiver"

  depends_on = [
    citrixadc_vpnsessionaction.gw_sess_act_receiver
  ]
}

resource "citrixadc_vpnsessionpolicy" "gw_sess_pol_receiver_web" {
  name = "sess_pol_sf_receiver_web"
  rule = "HTTP.REQ.HEADER(\"User-Agent\").CONTAINS(\"CitrixReceiver\").NOT" 
  action = "sess_prof_sf_receiver_web"

  depends_on = [
    citrixadc_vpnsessionaction.gw_sess_act_receiver_web
  ]
}

#####s
# Bind session policies to GW vServer
#####
resource "citrixadc_vpnvserver_vpnsessionpolicy_binding" "gw_vserver_vpnsessionpolicy_binding_receiver" {
  name      = citrixadc_vpnvserver.gw_vserver.name
  policy    = citrixadc_vpnsessionpolicy.gw_sess_pol_receiver.name
  priority  = 100

  depends_on = [
    citrixadc_vpnsessionpolicy.gw_sess_pol_receiver
  ]
}

resource "citrixadc_vpnvserver_vpnsessionpolicy_binding" "gw_vserver_vpnsessionpolicy_binding_receiver_web" {
  name      = citrixadc_vpnvserver.gw_vserver.name
  policy    = citrixadc_vpnsessionpolicy.gw_sess_pol_receiver_web.name
  priority  = 110

  depends_on = [
    citrixadc_vpnsessionpolicy.gw_sess_pol_receiver_web
  ]
}

resource "citrixadc_authenticationldapaction" "gw_authenticationldapaction" {
  count              = length(var.adc-gw-authenticationldapaction.name)
  name               = element(var.adc-gw-authenticationldapaction["name"],count.index)
  servername         = element(var.adc-gw-authenticationldapaction["servername"],count.index)
  ldapbase           = element(var.adc-gw-authenticationldapaction["ldapBase"],count.index)
  ldapbinddn         = element(var.adc-gw-authenticationldapaction["ldapBindDn"],count.index)
  ldapbinddnpassword = element(var.adc-gw-authenticationldapaction["ldapBindDnPassword"],count.index)
  ldaploginname      = element(var.adc-gw-authenticationldapaction["ldapLoginName"],count.index)
  groupattrname      = element(var.adc-gw-authenticationldapaction["groupAttrName"],count.index)
  subattributename   = element(var.adc-gw-authenticationldapaction["subAttributeName"],count.index)
  ssonameattribute   = element(var.adc-gw-authenticationldapaction["ssoNameAttribute"],count.index)
  sectype            = element(var.adc-gw-authenticationldapaction["secType"],count.index)
  passwdchange       = element(var.adc-gw-authenticationldapaction["passwdChange"],count.index)

    depends_on = [
      citrixadc_vpnvserver.gw_vserver
    ]
}

#####
# Bind authentication profile to policy
#####

resource "citrixadc_authenticationldappolicy" "gw_authenticationldappolicy" {
    count     = length(var.adc-gw-authenticationldappolicy.name)
    name      = element(var.adc-gw-authenticationldappolicy["name"],count.index)
    rule      = element(var.adc-gw-authenticationldappolicy["rule"],count.index)
    reqaction = element(var.adc-gw-authenticationldappolicy["reqaction"],count.index)

    depends_on = [
        citrixadc_authenticationldapaction.gw_authenticationldapaction
    ]
}

#####
# Bind authentication policies to GW vServer
#####

resource "citrixadc_vpnvserver_authenticationldappolicy_binding" "gw_vserver_authenticationldappolicy_binding" {
    name        = citrixadc_vpnvserver.gw_vserver.name
    policy      = var.adc-gw.authenticationpolicy
    priority    = 100
    bindpoint   = "REQUEST"
    
    depends_on = [
        citrixadc_authenticationldappolicy.gw_authenticationldappolicy
    ]
}

#####
# Bind SSL certificate to SSL GW vServers
#####

resource "citrixadc_sslvserver_sslcertkey_binding" "gw_sslvserver_sslcertkey_binding" {
  vservername = citrixadc_vpnvserver.gw_vserver.name
  certkeyname = "ssl_cert_${var.adc-base.environmentname}_Server"
  snicert     = false

  depends_on = [
    citrixadc_vpnvserver_authenticationldappolicy_binding.gw_vserver_authenticationldappolicy_binding
  ]
}

#####
# Save config
#####

resource "citrixadc_nsconfig_save" "gw_save" {    
  all        = true
  timestamp  = timestamp()

  depends_on = [
    citrixadc_sslvserver_sslcertkey_binding.gw_sslvserver_sslcertkey_binding
  ]
}
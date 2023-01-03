#####
# Add Citrix GW vServer
#####

resource "citrixadc_vpnvserver" "gw_vserver" {
  count           = length(var.adc-gw-vserver.name)
  name            = element(var.adc-gw-vserver["name"],count.index)
  servicetype     = element(var.adc-gw-vserver["servicetype"],count.index)
  ipv46           = element(var.adc-gw-vserver["ipv46"],count.index)
  port            = element(var.adc-gw-vserver["port"],count.index)
  dtls            = element(var.adc-gw-vserver["dtls"],count.index)
  tcpprofilename  = element(var.adc-gw-vserver["tcpprofilename"],count.index)
  httpprofilename = element(var.adc-gw-vserver["httpprofilename"],count.index)
  appflowlog      = element(var.adc-gw-vserver["appflowlog"],count.index)
}

#####
# Bind SSL profile to GW vServer
#####

resource "citrixadc_sslvserver" "gw_vserver_sslprofile" {
  count       = length(var.adc-gw-vserver.name)
  vservername = citrixadc_vpnvserver.gw_vserver[count.index].name
  sslprofile  = "ssl_prof_democloud_fe_TLS1213"

  depends_on = [
    citrixadc_vpnvserver.gw_vserver
  ]
}


#####
# Bind STA Servers to GW vServer
#####

resource "citrixadc_vpnvserver_staserver_binding" "gw_vserver_staserver_binding" {
  count          = length(var.adc-gw-vserver-staserverbinding.name)
  name           = element(var.adc-gw-vserver-staserverbinding["name"],count.index)
  staserver      = element(var.adc-gw-vserver-staserverbinding["staserver"],count.index)
  staaddresstype = element(var.adc-gw-vserver-staserverbinding["staaddresstype"],count.index)

  depends_on = [
    citrixadc_vpnvserver.gw_vserver
  ]
}

#####
# Add Session Action Receiver
#####

resource "citrixadc_vpnsessionaction" "gw_sess_act_receiver" {
  count                      = length(var.adc-gw-vpnsessionaction-receiver.name)
  name                       = element(var.adc-gw-vpnsessionaction-receiver["name"],count.index)
  clientlessmodeurlencoding  = element(var.adc-gw-vpnsessionaction-receiver["clientlessmodeurlencoding"],count.index)
  clientlessvpnmode          = element(var.adc-gw-vpnsessionaction-receiver["clientlessvpnmode"],count.index)
  defaultauthorizationaction = element(var.adc-gw-vpnsessionaction-receiver["defaultauthorizationaction"],count.index)
  dnsvservername             = element(var.adc-gw-vpnsessionaction-receiver["dnsvservername"],count.index)
  icaproxy                   = element(var.adc-gw-vpnsessionaction-receiver["icaproxy"],count.index)
  sesstimeout                = element(var.adc-gw-vpnsessionaction-receiver["sesstimeout"],count.index)
  sso                        = element(var.adc-gw-vpnsessionaction-receiver["sso"],count.index)
  ssocredential              = element(var.adc-gw-vpnsessionaction-receiver["ssocredential"],count.index)
  storefronturl              = element(var.adc-gw-vpnsessionaction-receiver["storefronturl"],count.index)
  transparentinterception    = element(var.adc-gw-vpnsessionaction-receiver["transparentinterception"],count.index)
  wihome                     = element(var.adc-gw-vpnsessionaction-receiver["wihome"],count.index)
  windowsautologon           = element(var.adc-gw-vpnsessionaction-receiver["windowsautologon"],count.index)

  depends_on = [
    citrixadc_vpnvserver.gw_vserver
  ]
}

#####
# Add Session Action Receiver Web
#####

resource "citrixadc_vpnsessionaction" "gw_sess_act_receiverweb" {
  count                      = length(var.adc-gw-vpnsessionaction-receiverweb.name)
  name                       = element(var.adc-gw-vpnsessionaction-receiverweb["name"],count.index)
  clientchoices              = element(var.adc-gw-vpnsessionaction-receiverweb["clientchoices"],count.index)
  clientlessmodeurlencoding  = element(var.adc-gw-vpnsessionaction-receiverweb["clientlessmodeurlencoding"],count.index)
  clientlessvpnmode          = element(var.adc-gw-vpnsessionaction-receiverweb["clientlessvpnmode"],count.index)
  defaultauthorizationaction = element(var.adc-gw-vpnsessionaction-receiverweb["defaultauthorizationaction"],count.index)
  dnsvservername             = element(var.adc-gw-vpnsessionaction-receiverweb["dnsvservername"],count.index)
  icaproxy                   = element(var.adc-gw-vpnsessionaction-receiverweb["icaproxy"],count.index)
  locallanaccess             = element(var.adc-gw-vpnsessionaction-receiverweb["locallanaccess"],count.index)
  rfc1918                    = element(var.adc-gw-vpnsessionaction-receiverweb["rfc1918"],count.index)
  sesstimeout                = element(var.adc-gw-vpnsessionaction-receiverweb["sesstimeout"],count.index)
  sso                        = element(var.adc-gw-vpnsessionaction-receiverweb["sso"],count.index)
  ssocredential              = element(var.adc-gw-vpnsessionaction-receiverweb["ssocredential"],count.index)
  wihome                     = element(var.adc-gw-vpnsessionaction-receiverweb["wihome"],count.index)
  windowsautologon           = element(var.adc-gw-vpnsessionaction-receiverweb["windowsautologon"],count.index)
  wiportalmode               = element(var.adc-gw-vpnsessionaction-receiverweb["wiportalmode"],count.index)

  depends_on = [
    citrixadc_vpnvserver.gw_vserver
  ]
}

#####
# Add Session Policies
#####

resource "citrixadc_vpnsessionpolicy" "gw_sess_pol_receiver" {
  count  = length(var.adc-gw-vpnsessionpolicy.name)
  name   = element(var.adc-gw-vpnsessionpolicy["name"],count.index)
  rule   = element(var.adc-gw-vpnsessionpolicy["rule"],count.index)
  action = element(var.adc-gw-vpnsessionpolicy["action"],count.index)

  depends_on = [
    citrixadc_vpnsessionaction.gw_sess_act_receiver,
    citrixadc_vpnsessionaction.gw_sess_act_receiverweb
  ]
}

#####s
# Bind session policies to GW vServer
#####

resource "citrixadc_vpnvserver_vpnsessionpolicy_binding" "gw_vserver_vpnsessionpolicy_binding" {
  count     = length(var.adc-gw-vserver-vpnsessionpolicybinding.name)
  name      = element(var.adc-gw-vserver-vpnsessionpolicybinding["name"],count.index)
  policy    = element(var.adc-gw-vserver-vpnsessionpolicybinding["policy"],count.index)
  priority  = element(var.adc-gw-vserver-vpnsessionpolicybinding["priority"],count.index)

  depends_on = [
    citrixadc_vpnsessionpolicy.gw_sess_pol_receiver
  ]
}

resource "citrixadc_authenticationldapaction" "gw_authenticationldapaction" {
  count              = length(var.adc-gw-vserver-authenticationldapaction.name)
  name               = element(var.adc-gw-vserver-authenticationldapaction["name"],count.index)
  servername         = element(var.adc-gw-vserver-authenticationldapaction["servername"],count.index)
  ldapbase           = element(var.adc-gw-vserver-authenticationldapaction["ldapBase"],count.index)
  ldapbinddn         = element(var.adc-gw-vserver-authenticationldapaction["ldapBindDn"],count.index)
  ldapbinddnpassword = element(var.adc-gw-vserver-authenticationldapaction["ldapBindDnPassword"],count.index)
  ldaploginname      = element(var.adc-gw-vserver-authenticationldapaction["ldapLoginName"],count.index)
  groupattrname      = element(var.adc-gw-vserver-authenticationldapaction["groupAttrName"],count.index)
  subattributename   = element(var.adc-gw-vserver-authenticationldapaction["subAttributeName"],count.index)
  ssonameattribute   = element(var.adc-gw-vserver-authenticationldapaction["ssoNameAttribute"],count.index)
  sectype            = element(var.adc-gw-vserver-authenticationldapaction["secType"],count.index)
  passwdchange       = element(var.adc-gw-vserver-authenticationldapaction["passwdChange"],count.index)

    depends_on = [
      citrixadc_vpnvserver.gw_vserver
    ]
}

resource "citrixadc_authenticationldappolicy" "gw_authenticationldappolicy" {
    count     = length(var.adc-gw-vserver-authenticationldappolicy.name)
    name      = element(var.adc-gw-vserver-authenticationldappolicy["name"],count.index)
    rule      = element(var.adc-gw-vserver-authenticationldappolicy["rule"],count.index)
    reqaction = element(var.adc-gw-vserver-authenticationldappolicy["reqaction"],count.index)

    depends_on = [
        citrixadc_authenticationldapaction.gw_authenticationldapaction
    ]
}

#####
# Bind authentication policies to GW vServer
#####

resource "citrixadc_vpnvserver_authenticationldappolicy_binding" "gw_vserver_authenticationldappolicy_binding" {
    count       = length(var.adc-gw-vserver-authenticationldappolicy_binding.name)
    name        = element(var.adc-gw-vserver-authenticationldappolicy_binding["name"],count.index)
    policy      = element(var.adc-gw-vserver-authenticationldappolicy_binding["policy"],count.index)
    priority    = element(var.adc-gw-vserver-authenticationldappolicy_binding["priority"],count.index)
    bindpoint   = element(var.adc-gw-vserver-authenticationldappolicy_binding["bindpoint"],count.index)
    
    depends_on = [
        citrixadc_authenticationldappolicy.gw_authenticationldappolicy
    ]
}

#####
# Bind SSL certificate to SSL GW vServers
#####

resource "citrixadc_sslvserver_sslcertkey_binding" "gw_sslvserver_sslcertkey_binding" {
    count       = length(var.adc-gw-vserver.name)
    vservername = element(var.adc-gw-vserver["name"],count.index)
    certkeyname = "ssl_cert_democloud"
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
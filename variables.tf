#####
# Variables for administrative connection to the ADC
#####

variable adc-base{
}

#####
# ADC GW vServer
#####

variable "adc-gw-vserver" {
}

#####
# ADC GW vServer STA Bindings
#####

variable "adc-gw-vserver-staserverbinding" {
}

#####
# Session Action Variables
#####

variable "adc-gw-vpnsessionaction-receiver" {
}

variable "adc-gw-vpnsessionaction-receiverweb" {
}

#####
# Session Policiy Variables
#####

variable "adc-gw-vpnsessionpolicy" {
}

#####
# ADC GW vServer VPN Session Policy Bindings
#####

variable "adc-gw-vserver-vpnsessionpolicybinding" {
}

#####
# ADC Authentication LDAP Action
#####

variable "adc-gw-vserver-authenticationldapaction" {
}

#####
# ADC Authentication LDAP Policy
#####

variable "adc-gw-vserver-authenticationldappolicy" {
}

#####
# ADC Authentication LDAP Policy GW vServer Binding
#####

variable "adc-gw-vserver-authenticationldappolicy_binding" {
}
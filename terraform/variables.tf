variable "compartment_ocid" {
  description = "Your OCI Compartment or Tenancy OCID"
  type        = string
  default     = "ocid1.tenancy.oc1..aaaaaaaa75ld3h45uahphb3abpxkkwwsemmplkajru7lguilcxdwsjeskcbq"
}

variable "ssh_public_key" {
  description = "Contents of your ~/.ssh/id_rsa.pub file"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFIl5/VFrNG2ukZg1GsnJDHtid/o5nRIvEU4LcJmeJxq7ATEBLCc0Awp8k3w6jkpG1+HZpFKrerK8xZjAbYN9+mSYvZAEXD58lhv2BR4RI/B3JavyW+bi/bCm77S76fsTDnfi1Sk+3Vf9Skwce8fMiiBWAmWJUTtAdS4lxaPhfx/A/j+gF3hOC1sXqFVov0MlkL2jiVI5miBh6WUpNz7zcSZ8r7pYEgTY4uF+3lNklLkRHzZt0nA2DBRrFLP4U9P9v3Se96rm1nBmSRoTFIKDZFlTluMNwZ34wUB7EX95kmkwdJj9idJKkSN0CxPOtOnRCBc0n/ogv048sBGZxVMmM78RcRMJQW95gnniibyRRYn0XjcxBJcNvt39Y3398e9/peJDAjm89aISRoj3LS7d4Snnn1d+O6m0RzQcoRxKl8W1oBhL3ilYEJsZ/9ZJYCde5s9xdaCbPhSbph5ZUcqxtNuCgfKJjtkSOH0zYTT1IuTA7LbHujISzqvnUqhsWQq+vQWQsekezifxj86pzZ7DpO4MMJqMFzvioxXYNRPlVlZu0Arfg0QzKtVwqa+oNxk+b1Qi6sQo89Q+EAscJY8nJWDHxqRReF+wjjb8yNRYKxYu6i21WkOdXz8dSxPkRvK+ve4sC0+w336L4E1/X+DK/Mm0Wl9R6QcObW7Q2YRFSmQ== user@Mondals"
}


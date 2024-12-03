LDAPGroupsLookup.config = {
  enabled: Settings.ldap[:enabled],
  config: { host: Settings.ldap[:host],
            port: Settings.ldap[:port] || 636,
            encryption: {
              method: :simple_tls,
              tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS,
            },
            auth: {
              method: :simple,
              username: "cn=#{Settings.ldap[:user]}",
              password: Settings.ldap[:pass],
            }
  },
  tree: Settings.ldap[:tree],
  account_ou: Settings.ldap[:account_ou],
  group_ou: Settings.ldap[:group_ou]
}

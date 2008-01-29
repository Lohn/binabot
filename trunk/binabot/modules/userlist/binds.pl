bindm(name    => 'modules::userlist::users',
      method  => 'got_subscribe',
      type    => 'subscribe',
      pattern => '.*?',
      tag     => 'presence'
      );
bindm(name    => 'modules::userlist::users',
      method  => 'statuschanged',
      type    => 'available',
      pattern => '^$',
      tag     => 'presence'
      );
bindm(name    => 'modules::userlist::users',
      method  => 'statuschanged',
      type    => 'unavailable',
      pattern => '^$',
      tag     => 'presence'
      );
bindm(name    => 'modules::userlist::users',
      method  => 'statuschanged',
      type    => '',
      pattern => '^$',
      tag     => 'presence'
      );
bindm(name    => 'modules::userlist::users',
      method  => 'initroster',
      type    => 'intern',
      pattern => '^RosterGet$',
      tag     => 'IPC'
      );
bindm(name    => 'modules::userlist::users',
      method  => 'getpass',
      type    => 'intern',
      pattern => '^getpass$',
      tag     => 'IPC'
      );
bindm(name    => 'modules::userlist::users',
      method  => 'setflags',
      type    => 'intern',
      pattern => '^setflags$',
      tag     => 'IPC'
      );
bindm(name    => 'modules::userlist::users',
      method  => 'AddContact',
      type    => 'intern',
      pattern => '^AddContact',
      tag     => 'IPC'
      );
bindm(name    => 'modules::userlist::users',
      method  => 'RemContact',
      type    => 'intern',
      pattern => '^RemContact',
      tag     => 'IPC'
      );
bindm(name    => 'modules::userlist::users',
      method  => 'updatecontactfile',
      type    => 'intern',
      pattern => '^updatecontactfile',
      tag     => 'IPC'
     );
bindm(name    => 'modules::userlist::users',
      method  => 'OwnerSetRealname',
      type    => 'intern',
      pattern => '^setrealname',
      tag     => 'IPC',
     );


sbind('modules::userlist::users','chpass','^chpass.*?');
sbind('modules::userlist::users','SetRealname','^setrealname');

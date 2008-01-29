#-*-cperl-*-
bindm(name    => 'modules::IPCadmin::irc',
      method  => 'ircstatus',
      type    => 'IPC',
      pattern => '^ircstatus.*',
      tag     => 'IPC'
     );
bindm(name    => 'modules::IPCadmin::irc',
      method  => 'privmsg',
      type    => 'IPC',
      pattern => '^privmsg',
      tag     => 'IPC'
     );
ipcbind('modules::IPCadmin::irc','ircconnect','^ircconnect');
ipcbind('modules::IPCadmin::irc','ircjoin','^ircjoin');
ipcbind('modules::IPCadmin::irc','ircpart','^ircpart');


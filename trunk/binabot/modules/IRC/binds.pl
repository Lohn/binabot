#-*-cperl-*-
bindm(name    => 'modules::IRC::jpbIRC',
      method  => 'IRCconnect',
      type    => 'intern',
      pattern => '^IRCconnect$',
      tag     => 'IPC'
     );
bindm(name    => 'modules::IRC::jpbIRC',
      method  => 'getconnections',
      type    => 'intern',
      pattern => '^getconnections$',
      tag     => 'IPC'
     );
bindm(name    => 'modules::IRC::jpbIRC',
      method  => 'getconnectionswithchans',
      type    => 'intern',
      pattern => '^getconnectionswithchans$',
      tag     => 'IPC'
     );
bindm(name    => 'modules::IRC::jpbIRC',
      method  => 'join',
      type    => 'intern',
      pattern => '^IRCjoin$',
      tag     => 'IPC'
      );
bindm(name    => 'modules::IRC::jpbIRC',
      method  => 'quit',
      type    => 'intern',
      pattern => '^IRCquit$',
      tag     => 'IPC'
      );
bindm(name    => 'modules::IRC::jpbIRC',
      method  => 'part',
      type    => 'intern',
      pattern => '^IRCpart$',
      tag     => 'IPC'
      );
bindm(name    => 'modules::IRC::test',
      method  => 'mytest',
      type    => 'IRC',
      pattern => '^test$',
      tag     => 'public',
      );
bindm(name    => 'modules::IRC::jpbIRC',
      method  => 'identify',
      type    => 'IRC',
      pattern => '^identify.*?',
      tag     => 'msg'
      );
bindm(name    => 'modules::IRC::test',
      method  => 'msgtest',
      type    => 'IRC',
      pattern => '^test$',
      tag     => 'msg'
      );
bindm(name    => 'modules::IRC::test',
      method  => 'bindtest',
      type    => 'IRC',
      pattern => '^bindtest',
      tag     => 'public',
      flags   => 'n'
      );
bindm(name    => 'modules::IRC::jpbIRC',
      method  => 'got_connected',
      type    => 'IRC',
      pattern => '^on_connect',
      tag     => 'connect'
      );
bindm(name    => 'modules::IRC::test',
      method  => 'whois',
      type    => 'IRC',
      pattern => '^!whois',
      tag     => 'public',
      flags   => 'n'
      );
bindm(name    => 'modules::IRC::jpbIRC',
      method  => 'dcc_get',
      type    => 'intern',
      pattern => '^dccget',
      tag     => 'IPC',
      flags   => ''
      );
bindm(name    => 'modules::IRC::test',
      method  => 'fu',
      type    => 'IRC',
      pattern => '^fu$',
      tag     => 'public',
      flags   => ''
      );
bindm(name    => 'modules::IRC::dcc',
      method  => 'GotAGet',
      type    => 'IRC',
      pattern => '^SEND',
      tag     => 'cdcc',
      flags   => 'f'
      );



      # Admin Commands

bindm(name    => 'modules::IRC::admin',
      method  => 'adduser',
      type    => 'IRC',
      pattern => '^\.adduser',
      tag     => 'msg',
      flags   => 'u',
      );
bindm(name    => 'modules::IRC::admin',
      method  => 'saveall',
      type    => 'IRC',
      pattern => '^\.save',
      tag     => 'msg',
      flags   => 'n'
     );
bindm(name    => 'modules::IRC::admin',
      method  => 'reloadall',
      type    => 'IRC',
      pattern => '^\.reload',
      tag     => 'msg',
      flags   => 'n'
     );
bindm(name    => 'modules::IRC::admin',
      method  => 'ownerhelp',
      type    => 'IRC',
      pattern => '^\.help',
      tag     => 'msg',
      flags   => 'n'
     );
bindm(name    => 'modules::IRC::jpbIRC',
      method  => 'privmsg',
      type    => 'intern',
      pattern => '^privmsg',
      tag     => 'IPC',
     );

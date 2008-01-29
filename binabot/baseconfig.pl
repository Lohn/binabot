######################################################################
#   JabberBot (C) Copyright 2001 by Kahless (tehkahless@jabber.org)  #
# Version 0.2                                                        #
#                                                                    #
######################################################################

$server     = "jabber.org";
$username   = "EditTheConfigFile";
$pass       = "EditTheConfigFile";
$owner      = 'tehkahless@jabber.org';
$debug      = 1;
$save       = 1;
$filename   = "jabbercontacts.txt";
$savefile   = "saved.xml";
$ipctimeout = 30; # Timeout for IPC (in seconds)
$Data::Dumper::Indent = 1;
$IPCcom     = 1;  # Activate IPC communication ?
$IRCbot     = 0;  # Activate IRC bot ?
$stdIRCnick = "JabberBot";
$IPCkey     = 3824; # Key for IPC

$localaddr  = 1;  # Hostname of your PC. (for vhosts)
                  #   $localaddr is just used for Net::IRC
                  #    don't really now if it works, please tell me ;)
                  # 0: takes the hostname out of the system settings
                  # 1: hopefully ignores the hostname and takes the default

$jabberbot  = 1;  # Activating jabber module ?
                  # (May you want only a IRC bot ?)
     ##############################################################
     ###                 Registering modules                    ###
     ##############################################################

########################################################
########################################################
# sbind (Standard bind modules)
# Syntax:
# sbind( <name of module> , <name of method> , <pattern for body> [, <type> [, <flags>]] );
# Default value for type: chat
###############
# bindm (Bind Modules)
#
# Syntax:
#bindm( name    => <name of module>,
#       method  => <name of method>,
#       type    => <type of message>,
#       pattern => <pattern for message body>,
#       tag     => <tag of message (e.g. presence)>
#       );
########################################################
########################################################
sbind('modules::userlist::users','getroster','^getroster');
sbind('modules::testm','gotsmth','^blah.*?');
sbind('modules::owner','pls'    ,'^pls.*?');

eval `cat modules/userlist/binds.pl` || die @!;
eval `cat modules/IRC/binds.pl` || die @! if $IRCbot;
eval `cat modules/IPCadmin/binds.pl` || die @!;
bindm(name    => 'modules::misc',
      method  => 'get_time',
      pattern => '^time$'
     );
bindm(name    => 'modules::misc',
      method  => 'get_help',
      pattern => '^help'
     );
bindm(name    => 'modules::misc',
      method  => 'got_invitation',
      type    => 'normal',
      pattern => '.*'
      );
bindm(name    => 'modules::misc',
      method  => 'got_groupchat_time',
      type    => 'groupchat',
      pattern => '^time$'
     );
bindm(name    => 'modules::groupchat',
      method  => 'part',
      type    => 'groupchat',
      pattern => '^part$'
      );
bindm(name    => 'modules::fromouter',
      method  => 'getstatus',
      type    => 'IPC',
      pattern => '^getstatus.*?',
      tag     => 'IPC'
      );
bindm(name    => 'modules::fromouter',
      method  => 'sendmessage',
      type    => 'IPC',
      pattern => '^sendmessage.*?',
      tag     => 'IPC'
      );
1;

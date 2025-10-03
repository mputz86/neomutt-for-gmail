(import ./lib.nix) {
  name = "neomutt-gmail-config-check";
  
  nodes = {
    machine = { self, pkgs, config, ... }: {
      imports = [ 
        self.inputs.home-manager.nixosModules.home-manager
      ];
      
      users.users.testuser = {
        isNormalUser = true;
        uid = 1000;
      };
      
      home-manager.users.testuser = {
        imports = [ self.homeManagerModules.default ];
        
        home.stateVersion = "23.11";
        
        accounts.email.accounts.gmail = {
          address = "test@gmail.com";
          userName = "test@gmail.com";
          flavor = "gmail.com";
          passwordCommand = "echo 'test'";
          realName = "Test User";
          primary = true;
          maildir.path = "gmail";
        };
      };
    };
  };
  
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    
    # Check neomutt config has muttdown sendmail
    output = machine.succeed("cat /home/testuser/.config/neomutt/neomuttrc")
    assert "muttdown --sendmail-passthru --force-markdown" in output, "muttdown not configured as sendmail"
    
    # Check neomutt config has virtual mailboxes
    assert 'virtual-mailboxes "Inbox"' in output, "Inbox virtual mailbox not configured"
    assert 'virtual-mailboxes "Starred"' in output, "Starred virtual mailbox not configured"
    
    # Check neomutt config has Gmail keybindings
    assert "modify-labels>+spam" in output, "Spam keybinding not configured"
    assert "modify-labels>+archive" in output, "Archive keybinding not configured"
    
    # Check that programs are enabled (configs will be generated)
    machine.succeed("test -f /home/testuser/.config/neomutt/neomuttrc")
    
    print("All config checks passed!")
  '';
}
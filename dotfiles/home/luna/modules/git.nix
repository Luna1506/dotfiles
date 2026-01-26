{ git-name, git-email, ... }:

{
  programs.git = {
    enable = true;
    settings.user = {
      name = git-name;
      email = git-email;
    };
    settings = {
      init.defaultBranch = "main";
    };
  };
}


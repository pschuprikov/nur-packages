
# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build Status](https://travis-ci.com/pschuprikov/nur-packages.svg?branch=master)](https://travis-ci.com/pschuprikov/nur-packages)
[![Cachix Cache](https://img.shields.io/badge/cachix-<YOUR_CACHIX_CACHE_NAME>-blue.svg)](https://<YOUR_CACHIX_CACHE_NAME>.cachix.org)

## Steps left:

3. Add your NUR repo name and your cachix repo name (optional) to
   [.travis.yml](./.travis.yml)
   * If you use cachix you should also add your cache's private key to travis'
     protected env variables
4. Enable travis for your repo
   * You can add a cron job in the repository settings on travis to keep your
     cachix cache fresh
5. Change your travis and cachix names on the README template section and delete
   the rest
6. [Add yourself to NUR](https://github.com/nix-community/NUR#how-to-add-your-own-repository)

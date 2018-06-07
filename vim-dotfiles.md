## Changelist
1. init spf13-vim.sh to welkinspring github url and vim-plug, please not change this names.
2. remove fork mantianer
3. the load order for the configuation:
    spf13-vim.sh
	1. .vimrc.plugs.default
		2. .vimrc.before
			3. .vimrc.before.local
	
		4. .vimrc.plugs
			5. .vimrc.plugs.local

	6. .vimrc
	7. .vimrc.local
4. TBD
	spf13_bundle_groups = {}  select plugins
let g:spf13_plug_groups=['smartcomplete', 'python', 'php', 'javascript', 'html','airline']


There is an additional tier of customization available to those who want to maintain a
fork of spf13-vim specialized for a particular group. These users can create `.vimrc.fork`
and `.vimrc.bundles.fork` files in the root of their fork.  The load order for the configuration is:

1. `.vimrc.before` - spf13-vim before configuration
2. `.vimrc.before.fork` - fork before configuration
3. `.vimrc.before.local` - before user configuration
4. `.vimrc.bundles` - spf13-vim bundle configuration
5. `.vimrc.bundles.fork` - fork bundle configuration
6. `.vimrc.bundles.local` - local user bundle configuration
6. `.vimrc` - spf13-vim vim configuration
7. `.vimrc.fork` - fork vim configuration
8. `.vimrc.local` - local user configuration


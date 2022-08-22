<h1 align="center">prettierrc.nvim</h1>
<p align="center"><sup>Editor settings via prettier config</sup></p>

### Installation

- With [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use('numToStr/prettierrc.nvim')
```

- With [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'numToStr/prettierrc.nvim'
```

And that's it. Restart your neovim to see the magic.

### Support

#### Options

Following options are supported:

- [`printWidth`](https://prettier.io/docs/en/options.html#print-width)
- [`tabWidth`](https://prettier.io/docs/en/options.html#tab-width)
- [`useTabs`](https://prettier.io/docs/en/options.html#tabs)
- [`endOfLine`](https://prettier.io/docs/en/options.html#end-of-line)

#### Files

Following [config files](https://prettier.io/docs/en/configuration.html) are supported in the respective order.

- `.prettierrc`
- `.prettierrc.json`
- `.prettierrc.yml`
- `.prettierrc.yaml`
- `.prettierrc.toml`

Keep in mind, there is no support for nested configuration as of now.

- Supported

```json
{
  "trailingComma": "es5",
  "tabWidth": 4,
  "printWidth": 100
}
```

- Not Supported

```json
{
  "semi": false,
  "overrides": [
    {
      "files": "*.test.js",
      "options": {
        "semi": true
      }
    },
    {
      "files": ["*.html", "legacy/**/*.js"],
      "options": {
        "tabWidth": 4
      }
    }
  ]
}
```

### Limitation

Following filetype/format are not supported

- `.prettierrc.{js,cjs}` and `.prettierrc.config.{js,cjs}` - I am not going to create a javascipt parser
- `package.json` (`prettier` option) - Technically, it's possible to support but I am lazy.

### Contributing

You can contribute to the project by filing [bug reports](https://github.com/numToStr/prettierrc.nvim/issues) or submit PR :)

### Credits

- [`editorconfig.nvim`](https://github.com/gpanders/editorconfig.nvim) - For motivation and guidance

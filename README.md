<h1 align="center">md-pdf-link.nvim</h1>

> [!NOTE]
> Neovim plugin for integrating PDF documents in markdown files

> [!IMPORTANT]
> If you want to help add support for other PDF readers, check the [contributing guide](CONTRIBUTING.md)
> - [x] Zathura

> [!WARNING]
> This plugin relies on the following (optional) system dependencies:
> - **Zathura**: currently the only supported document reader
> - **poppler-utils**: for converting PDFs to text files (wordlist)
> - **dbus**: for communicating with the document reader instance (pasting)

## Features

- **open** a markdown link to a PDF document at an exact page
    - format: `[DESCRIPTION (PAGENR)](PDF_LINK)`
- **paste** the currently opened PDF page as a markdown link under the cursor
- **wordlist** for auto-completion of the currently opened PDF document

## Usage

### Setup

This plugin will be autoloaded upon entering a markdown file.
The default config looks like this:

>[!NOTE]
> If you are fine with the defaults calling `setup` is **not required**

```lua
require("md-pdf-link").setup {
    markdown_link = {
        -- default description to put in a markdown link `[DESCRIPTION](LINK)`
        description = "Pdf"
    },
}
```

### Keymaps

Example Keymaps:
```lua
vim.keymap.set(
    "n", "<leader>po", "<Plug>(MdPdfLinkOpen)",
    {
        desc = "open markdown link to pdf",
        silent = true,
    }
)

vim.keymap.set("n", "<leader>pp", "<Plug>(MdPdfLinkPaste)",
    {
        desc = "paste currently open pdf page as markdown link",
        silent = true,
    }
)

vim.keymap.set("n", "<leader>pl", "<Plug>(MdPdfLinkWordList)",
    {
        desc = "create a dictionary for autocompletion from markdown link under the cursor",
        silent = true,
    }
)
```

### Commands

There are also the following commands:
```
:MdPdfLink open
:MdPdfLink paste
:MdPdfLink wordlist
```

## Installation

### vim.pack

```lua
local gh = function(x) return 'https://github.com/' .. x end
vim.pack.add({
    { src = gh("integeresting/md-pdf-link.nvim")},
})
```

### lazy.nvim

```lua
{
    'integeresting/md-pdf-link.nvim',
    opts = { --[[...]] },
}
```

## Philosophy

**I take and view my notes in Neovim.**
Plain text never breaks and I am always able to view, search and process my
notes in the way I see fit. Since they are also light weight, backups / version
control with git is a breeze. The only structure (and eye candy) on top with a
reasonable compromise is markdown.
I don't think I need to explain why Neovim is great for editing text.

**Of course, this has some obvious short-comings.**
Some things are better expressed visually or in a more complex format.
For diagrams and images I like to use an [Excalidraw wrapper](https://github.com/integeresting/excalidraw-desktop)
I made for local offline use. The other big group are complex math formulas. I
tried some inline LaTeX renderers but ultimately wasn't happy with the
integration plus this view isn't always available outside of Neovim.

**I like writing math and other complex documents with Typst**
For the first 3 years of taking math notes I wrote everything in LaTeX, which is
the de facto standard I'd say. However I was very dissatisfied with the local
experience, the tooling and language syntax at times. After seeing some [Typst](https://typst.app/)
and trying it out for myself, I found all my issues vaporized. The scripting
language is rich and very accessible, the documentation is extensive and the cli
tool + lsp are solid.

**So now I write the simple parts in markdown and express everything else with
Typst and PDFs.**
Often times I find myself referencing a PDF document anyways so they became my
common interface for the complex parts of my notes. Through this workflow I
slowly solidified this plugin to help speed up linking to and from documents.

**As an example** they are very handy for taking notes in university classes.
There is no need and or not enough time to copy the contents of the slides.
Writing notes based on my own understanding and findings I can then annotate
them with the exact slide containing complex math formulas or diagrams while
easily keeping up with the lecture. Before I often needed to do some major
refactoring at home after.

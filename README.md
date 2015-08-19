# Dashy
> Selector combinators and other helpers for Sass...

This is going to take a while to document, so in the meantime, here's how Dashy looks in the wild:

```scss
#{ select-table-groups-rows-cells('.vertically-striped', '*', select-odd-siblings(100)) }
{
    background-color:gray;
}

#{ select-table-groups-rows-cells('.vertically-ruled', '*', '* + *') }
{
    border-left:1px solid black;
}

#{ select-table-groups-rows-cells('.lightly-vertically-ruled', '*', '* + *') }
{
    border-left:1px solid gray;
}

#{ select-table-groups-rows-cells('.horizontally-striped', select-odd-siblings(100)) }
{
    background-color:gray;
}

#{ select-table-groups-rows-cells('.horizontally-ruled', '* + *') }
{
    border-top:1px solid black;
}

#{ select-table-groups-rows-cells('.lightly-horizontally-ruled', '* + *') }
{
    border-top:1px solid gray;
}
```

open React
// TODO: how can I rename a library? For example `MaterialUi` to `Mui`
open MaterialUi

type rec item = {
  id: string,
  name: string,
  items: array<item>,
}

type contextType = {
  selectedItemId: option<string>,
  isItemOpen: item => bool,
  onSelectItem: item => unit,
}

let context: Context.t<contextType> = createContext({
  selectedItemId: None,
  isItemOpen: _ => false,
  onSelectItem: _ => (),
})

module ContextProvider = {
  let provider = Context.provider(context)

  @react.component
  let make = (~value, ~children) => {
    createElement(provider, {"value": value, "children": children})
  }
}

module rec TreeItem: {
  @react.component
  let make: (~item: item, ~level: int) => element
} = {
  open Belt
  open ReactDOM

  // NOTE: (mui) it'd be nice to use `React.useTheme` and write `let paddingLeft = theme.spacing(2)`
  let paddingLeft = 16

  @react.component
  let make = (~item, ~level) => {
    // NOTE: (react) it'd be nice to write `useState(false)`
    let (isOpen, setOpen) = useState(() => false)
    let {isItemOpen, selectedItemId} = useContext(context)

    useEffect1(() => {
      setOpen(_ => isItemOpen(item))
      None
    }, [item.id, selectedItemId->Option.getWithDefault("")])

    <>
      <ListItem
        selected={Some(item.id) == selectedItemId}
        // NOTE: (react) it's be nice to simply write `button` (omit `true`)
        button=true
        // NOTE: (react) it'd be nice to accept numerical values
        style=Style.make(~paddingLeft=`${(paddingLeft * level)->Int.toString}px`, ())
        onClick={_ => setOpen(value => !value)}>
        {item.name->string}
      </ListItem>
      // NOTE: (react?) it'd be nice to shorcut this expression (something like {cond && <Comp />})
      {item.items->Array.length > 0
        ? <Collapse _in=isOpen> <TreeList items=item.items level={level + 1} /> </Collapse>
        : null}
    </>
  }
}
and TreeList: {
  @react.component
  let make: (~items: array<item>, ~level: int) => element
} = {
  open Belt.Array

  @react.component
  let make = (~items, ~level) => {
    <List> {items->map(item => <TreeItem key=item.id item level=level />)->array} </List>
  }
}

@react.component
let make = (~items: array<item>, ~selectedItemId: option<string>=?) => {
  open Belt.Array

  let rec isItemOpen = item => {
    selectedItemId == Some(item.id) || item.items->some(x => isItemOpen(x))
  }
  let onSelectItem = _ => ()

  <ContextProvider
    value={
      selectedItemId: selectedItemId,
      isItemOpen: isItemOpen,
      onSelectItem: onSelectItem,
    }>
    <TreeList items=items level=1 />
  </ContextProvider>
}
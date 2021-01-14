open React
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
  // TODO: something like `open Belt.{Option, Int}` ?
  open Belt

  @react.component
  let make = (~item, ~level) => {
    // WTF: () => false ?? why not simply `false` ?
    let (isOpen, setOpen) = useState(() => false)
    let {isItemOpen, selectedItemId} = useContext(context)
    // ISSUE: it'd be nice to accept numerical values
    let style = ReactDOM.Style.make(~paddingLeft=`${(8 * level)->Int.toString}px`, ())

    useEffect1(() => {
      setOpen(_ => isItemOpen(item))
      None
    }, [item.id, selectedItemId->Option.getWithDefault("")])

    <>
      // WTF: button=true ??
      <ListItem
        button=true
        style=style
        onClick={_ => setOpen(value => !value)}>
        {item.name->string}
      </ListItem>
      // TODO: is there a more concise way to express this?
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
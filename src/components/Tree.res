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
  let make: (~item: item) => element
} = {
  open Belt.Option

  @react.component
  let make = (~item: item) => {
    // WTF: () => false ?? why not simply `false` ?
    let (isOpen, setOpen) = useState(() => false)
    let {isItemOpen, selectedItemId} = useContext(context)

    useEffect1(() => {
      setOpen(_ => isItemOpen(item))
      None
    }, [item.id, selectedItemId->getWithDefault("")])

    <>
      // WTF: button=true ??
      <ListItem button=true onClick={_ => setOpen(value => !value)}> {item.name->string} </ListItem>
      // TODO: is there a more concise way to express this?
      {item.items->Array.length > 0
        ? <Collapse _in=isOpen> <TreeList items=item.items /> </Collapse>
        : null}
    </>
  }
}
and TreeList: {
  @react.component
  let make: (~items: array<item>) => element
} = {
  open Belt.Array

  @react.component
  let make = (~items: array<item>) => {
    <List> {items->map(item => <TreeItem key=item.id item />)->array} </List>
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
    <TreeList items={items} />
  </ContextProvider>
}
open React
open MaterialUi
open Belt.Array

type rec item = {
  id: string,
  name: string,
  items: array<item>,
}

module Context = {
  let ctx: Context.t<{
    "selectedItemId": option<string>,
    "isItemOpen": item => bool,
    "onSelectItem": item => unit,
  }> = createContext({
    "selectedItemId": None,
    "isItemOpen": _ => false,
    "onSelectItem": _ => (),
  })

  module Provider = {
    let provider = Context.provider(ctx)

    @react.component
    let make = (~value, ~children) => {
      createElement(provider, {"value": value, "children": children})
    }
  }
}

module rec TreeItem: {
  @react.component
  let make: (~item: item) => element
} = {
  @react.component
  let make = (~item: item) => {
    // WTF: () => false ?? why not simply `false` ?
    let (isOpen, setOpen) = useState(() => false)

    <>
      // WTF: button=true ??
      <ListItem button=true onClick={_ => setOpen(value => !value)}>
        {item.name->string}
      </ListItem>
      <Collapse _in=isOpen>
        <TreeList items=item.items />
      </Collapse>
    </>
  }
}
and TreeList: {
  @react.component
  let make: (~items: array<item>) => element
} = {
  @react.component
  let make = (~items: array<item>) => {
    <List>
      {items->map(item => <TreeItem key=item.id item />)->array}
    </List>
  }
}

@react.component
let make = (~items: array<item>) => {
  let isItemOpen = _ => false
  let onSelectItem = _ => ()

  <Context.Provider
    value={
      "selectedItemId": None,
      "isItemOpen": isItemOpen,
      "onSelectItem": onSelectItem,
    }>
    <TreeList items={items} />
  </Context.Provider>
}
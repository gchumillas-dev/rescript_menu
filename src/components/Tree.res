open React
open MaterialUi
open Belt.Array

type rec item = {
  id: string,
  name: string,
  items: array<item>,
}

let context: Context.t<{
  "selectedItemId": option<string>,
  "isItemOpen": item => bool,
  "onSelectItem": item => unit,
}> = createContext({
  "selectedItemId": None,
  "isItemOpen": _ => false,
  "onSelectItem": _ => (),
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
  @react.component
  let make = (~item: item) => {
    // WTF: () => false ?? why not simply `false` ?
    let (isOpen, setOpen) = useState(() => false)

    <>
      // WTF: button=true ??
      <ListItem button=true onClick={_ => setOpen(value => !value)}>
        {item.name->string}
      </ListItem>
      // TODO: is there a more concise way to express this?
      {item.items->length > 0
        ? (
            <Collapse _in=isOpen>
              <TreeList items=item.items />
            </Collapse>
          )
        : null}
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

  <ContextProvider
    value={
      "selectedItemId": None,
      "isItemOpen": isItemOpen,
      "onSelectItem": onSelectItem,
    }>
    <TreeList items={items} />
  </ContextProvider>
}
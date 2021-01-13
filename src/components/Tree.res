open React
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

module rec Item: {
  @react.component
  let make: (~item: item) => element
} = {
  @react.component
  let make = (~item: item) => {
    <>
      <li id=item.id>{item.name->string}</li>
      <List items=item.items />
    </>
  }
}
and List: {
  @react.component
  let make: (~items: array<item>) => element
} = {
  @react.component
  let make = (~items: array<item>) => {
    <ul> {items->map(item => <Item item />)->array} </ul>
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
    <List items={items} />
  </Context.Provider>
}
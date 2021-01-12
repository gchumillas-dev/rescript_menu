open Belt.Array

type rec item = {
  id: string,
  name: string,
  items: array<item>,
}

module Context = {
  let ctx: React.Context.t<{
    "selectedItemId": option<string>,
    "isItemOpen": item => bool,
    "onSelectItem": item => unit,
  }> = React.createContext({
    "selectedItemId": None,
    "isItemOpen": _ => false,
    "onSelectItem": _ => (),
  })

  module Provider = {
    let provider = React.Context.provider(ctx)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}

// Defines a recursive module.
module rec Item: {
  @react.component
  let make: (~item: item) => React.element
} = {
  @react.component
  let make = (~item: item) => {
    <> <li id=item.id> {React.string(item.name)} </li> <List items=item.items /> </>
  }
}
and List: {
  @react.component
  let make: (~items: array<item>) => React.element
} = {
  @react.component
  let make = (~items: array<item>) => {
    <ul> {items->map(item => <Item item />)->React.array} </ul>
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
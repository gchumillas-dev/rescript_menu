module Mui = MaterialUi

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

let context: React.Context.t<contextType> = React.createContext({
  selectedItemId: None,
  isItemOpen: _ => false,
  onSelectItem: _ => (),
})

module ContextProvider = {
  let provider = React.Context.provider(context)

  @react.component
  let make = (~value, ~children) => {
    React.createElement(provider, {"value": value, "children": children})
  }
}

module rec TreeItem: {
  @react.component
  let make: (~item: item, ~level: int) => React.element
} = {
  open Belt
  open ReactDOM

  // NOTE: (mui) it'd be nice to use `React.useTheme` and write `let paddingLeft = theme.spacing(2)`
  let paddingLeft = 16

  @react.component
  let make = (~item, ~level) => {
    // NOTE: (react) it'd be nice to write `useState(false)`
    let (isOpen, setOpen) = React.useState(() => false)
    let {isItemOpen, selectedItemId, onSelectItem} = React.useContext(context)
    // TODO: is there an `empty` function? Maybe `Array.length` is poor in performance.
    let hasChildren = item.items->Array.length > 0
    let icon = if hasChildren {
      isOpen ? <OpenFolderIcon /> : <FolderIcon />
    } else {
      <FileIcon />
    }

    React.useEffect1(() => {
      setOpen(_ => isItemOpen(item))
      None
    }, [item.id, selectedItemId->Option.getWithDefault("")])

    <>
      <Mui.ListItem
        selected={Some(item.id) == selectedItemId}
        // NOTE: (react) it'd be nice to simply write `button` (omit `true`)
        button=true
        // NOTE: (react) it'd be nice to accept numerical values
        style=Style.make(~paddingLeft=`${(paddingLeft * level)->Int.toString}px`, ())
        onClick={_ => onSelectItem(item)}>
        <Mui.ListItemIcon>icon</Mui.ListItemIcon>
        <Mui.ListItemText>{item.name->React.string}</Mui.ListItemText>
        {hasChildren
          ? (
            <Mui.ListItemSecondaryAction>
              // NOTE: (mui) `Mui.IconButton.Edge._end` ? sure ??
              <Mui.IconButton edge=Mui.IconButton.Edge._end onClick={_ => setOpen(value => !value)}>
                {isOpen ? <CollapseIcon /> : <ExpandIcon />}
              </Mui.IconButton>
            </Mui.ListItemSecondaryAction>
          )
          : React.null}
      </Mui.ListItem>
      // NOTE: (react?) it'd be nice to shorcut this expression (something like {cond && <Comp />})
      {hasChildren
        ? <Mui.Collapse _in=isOpen> <TreeList items=item.items level={level + 1} /> </Mui.Collapse>
        : React.null}
    </>
  }
}
and TreeList: {
  @react.component
  let make: (~items: array<item>, ~level: int) => React.element
} = {
  open Belt

  @react.component
  let make = (~items, ~level) => {
    <Mui.List>
      {items->Array.map(item => <TreeItem key=item.id item level=level />)->React.array}
    </Mui.List>
  }
}

@react.component
let make = (
  ~items: array<item>,
  ~selectedItemId: option<string> = ?,
  ~onSelectItem: item => unit
) => {
  open Belt

  let rec isItemOpen = item => {
    selectedItemId == Some(item.id) || item.items->Array.some(x => isItemOpen(x))
  }

  <ContextProvider
    value={
      selectedItemId: selectedItemId,
      isItemOpen: isItemOpen,
      onSelectItem: onSelectItem,
    }>
    <TreeList items=items level=1 />
  </ContextProvider>
}

open React

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

module FolderIcon = {
  @react.component @bs.module("@material-ui/icons/Folder")
  external make: (~color: string=?, ~className: string=?, ~fontSize: string=?,) => React.element = "default"
}

module OpenFolderIcon = {
  @react.component
  let make = () => {
    open ReactDOM

    <svg style=Style.make(~width="24px", ~height="24px", ()) viewBox="0 0 24 24">
      <path
        fill="currentColor"
        d="M19,20H4C2.89,20 2,19.1 2,18V6C2,4.89 2.89,4 4,4H10L12,6H19A2,2 0 0,1 21,8H21L4,8V18L6.14,10H23.21L20.93,18.5C20.7,19.37 19.92,20 19,20Z"
      />
    </svg>
  }
}

module FileIcon = {
  @react.component
  let make = () => {
    open ReactDOM

    <svg style=Style.make(~width="24px", ~height="24px", ()) viewBox="0 0 24 24">
      <path
        fill="currentColor"
        d="M13,9V3.5L18.5,9M6,2C4.89,2 4,2.89 4,4V20A2,2 0 0,0 6,22H18A2,2 0 0,0 20,20V8L14,2H6Z"
      />
    </svg>
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
    // TODO: replace length by empty?
    let icon = switch item.items->Belt.Array.length {
    | len when len > 0 => isOpen ? <OpenFolderIcon /> : <FolderIcon />
    | _ => <FileIcon />
    }

    useEffect1(() => {
      setOpen(_ => isItemOpen(item))
      None
    }, [item.id, selectedItemId->Option.getWithDefault("")])

    <>
      <Mui.ListItem
        selected={Some(item.id) == selectedItemId}
        // NOTE: (react) it's be nice to simply write `button` (omit `true`)
        button=true
        // NOTE: (react) it'd be nice to accept numerical values
        style=Style.make(~paddingLeft=`${(paddingLeft * level)->Int.toString}px`, ())
        onClick={_ => setOpen(value => !value)}>
        <Mui.ListItemIcon>icon</Mui.ListItemIcon>
        {item.name->string}
      </Mui.ListItem>
      // NOTE: (react?) it'd be nice to shorcut this expression (something like {cond && <Comp />})
      {item.items->Array.length > 0
        ? <Mui.Collapse _in=isOpen> <TreeList items=item.items level={level + 1} /> </Mui.Collapse>
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
    <Mui.List> {items->map(item => <TreeItem key=item.id item level=level />)->array} </Mui.List>
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
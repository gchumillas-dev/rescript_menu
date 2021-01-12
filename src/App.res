%%raw(`import './App.css';`)

@bs.module("./logo.svg") external logo: string = "default"

@react.component
let make = () => {
  let items: array<Tree.item> = [{
    id: "1",
    name: "Item 1",
    items: [{
      id: "11",
      name: "Item 11",
      items: [{
        id: "111",
        name: "Item 111",
        items: []
      }]
    }, {
      id: "12",
      name: "Item 12",
      items: []
    }]
  }, {
    id: "2",
    name: "Item 2",
    items: [{
      id: "21",
      name: "item 21",
      items: []
    }]
  }, {
    id: "3",
    name: "Item 3",
    items: []
  }]

  <div className="App">
    <Tree items={items} />
  </div>
}

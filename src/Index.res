open ReactDomExperimental

%%raw(`import './Index.css';`)

switch createRootWithId("root") {
| Some(root) => root->render(<App />)
| None => ()
}

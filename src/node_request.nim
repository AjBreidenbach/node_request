import jsffi
const native = slurp("native.js")

{.emit: native.}

type Request = distinct JsObject
type HttpCallback = proc(data: JsObject, error: JsObject)

proc request*(url, m: cstring): Request {.importc.}
proc header*(r: Request, key, value: cstring): Request {.importc.}
proc encoding*(r: Request, encoding: cstring): Request {.importc.}
proc body*(r: Request, body: cstring): Request {.importc.}
proc send*(r: Request) {.importc.}

proc callback(r: Request, fn: JsObject): Request {.importc.}
proc callback*(r: Request, fn: HttpCallback): Request =
  callback(r, toJs fn)

when isMainModule:
  import strformat
  const host = "100.115.92.201:5000"
  import json
  const putgoal =  &"http://{host}/%3C@292677584859168768%3E/goals/dance"

  let b = %*{
    "value": 1,
    "weight": 100,
    "description": ""
  }
  proc s1 =
    request(putgoal, "put")
      .body($b)
      .header("Content-Type", "application/json")
      .header("Content-Length", $ ($b).len)
      .send()

  
  const getgoals = &"http://{host}/%3C@292677584859168768%3E/goals"
  proc s2 =
    request(getgoals, "get")
      .encoding("utf8")
      .callback(
        proc(d, e: JsObject) =
          echo d.to(cstring)
      )
      .send()
  
  s1()
  s2()

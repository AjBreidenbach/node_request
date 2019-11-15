const http = require('http')

function request(url, method) {
    return {url, options: {method}}
}

function header(request, key, value) {
    if (!request.options.headers) request.options.headers = {}
    request.options.headers[key] = value
    return request
}

function encoding(request, encoding) {
    request.encoding = encoding
    return request
}

function body(request, body) {
    request.body = body
    header(request, 'Content-Length', Buffer.byteLength(body))
    return request
}


function callback(request, fn) { request.cb = fn ; return request}


function send(request) {
    let 
        response = {},
        req = http.request(
            request.url, 
            request.options,
            (res) => {
                if (request.encoding) res.setEncoding(request.encoding)
                res.on('data', (chunk) => response.data = response.data ? response.data.concat(chunk) : chunk)
                res.on('error', (e) => response.error = e)
                if (request.cb) res.on('end', _ => request.cb(response.data, response.error))
            }
        )
    if (request.body) {
        req.write(request.body)
    }
    req.end()
}

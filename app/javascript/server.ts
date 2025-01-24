export async function fetchJSON(url:string, method:string, parameters = {}):Promise<Response> {
    const headers = {
        Accept: "application/json",
        "Content-Type": "application/json;charset=UTF-8",
        "X-CSRF-TOKEN": ""
    };
    const csrfTokenElement = document.querySelector('meta[name="csrf-token"]');
    if (csrfTokenElement) {
        headers["X-CSRF-TOKEN"] = (csrfTokenElement as HTMLMetaElement).content;
    }
    return fetch(
        url,
        {
            method: method.toUpperCase(),
            headers: headers,
            body: JSON.stringify(parameters)
        }
    )
}

export async function post(url:string, parameters = {}):Promise<Response> {
    return await fetchJSON(url, "POST", parameters);
}

export async function patch(url:string, parameters = {}):Promise<Response> {
    return await fetchJSON(url, "PATCH", parameters);
}

export async function destroy(url:string, parameters = {}):Promise<Response> {
    return await fetchJSON(url, "DELETE", parameters);
}

export async function post(url:string, parameters = {}):Promise<Response> {
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
            method: "POST",
            headers: headers,
            body: JSON.stringify(parameters)
        }
    )
}
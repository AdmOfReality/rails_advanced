// app/javascript/controllers/comment_submit.js
document.addEventListener("submit", async (e) => {
  if (e.target.matches("form[data-type='json']")) {
    e.preventDefault()
    const form = e.target
    const data = new FormData(form)

    const response = await fetch(form.action, {
      method: "POST",
      headers: {
        "Accept": "application/json"
      },
      body: data
    })

    if (response.ok) {
      form.reset()
    } else {
      const json = await response.json()
      alert(json.errors.join(", "))
    }
  }
})

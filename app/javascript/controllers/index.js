import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Используем require.context для динамического импорта всех контроллеров
const context = require.context("./", true, /_controller\.js$/)

context.keys().forEach((key) => {
  const module = context(key) // require.context сразу возвращает модуль, без промиса

  const name = key
    .replace("./", "")
    .replace("_controller.js", "")
    .replace(/\//g, "--")

  application.register(name, module.default)
})

export { application }

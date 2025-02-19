import $ from "jquery";
window.$ = $;
window.jQuery = $;

// import { Turbo } from "@hotwired/turbo-rails";
// import "controllers";

// Подключаем Rails UJS
import Rails from "@rails/ujs";
Rails.start();
window.Rails = Rails; // Делаем глобальным

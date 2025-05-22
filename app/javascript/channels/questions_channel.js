import consumer from "./consumer"

consumer.subscriptions.create("QuestionsChannel", {
  connected() {
    // this.perform("subscribed")
  },

  received(data) {
    $('.questions').append(data);
  }
});

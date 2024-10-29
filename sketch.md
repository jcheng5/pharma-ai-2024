### Introduction

I have to admit, it feels strange to be here talking about AI.

And I've hopefully made it very clear by the title of my talk, I'm going to be speaking about AI in a positive light.

That's weird for me because up until a few months ago, I was pretty skeptical about AI. Not necessarily skeptical about its capabilities, but, skeptical that its impact was going to measure up to the hype.

And especially, I was skeptical that whatever impact it did have on our profession, our society, our species, even our planet--that that impact was going to be positive.

And not only was I skeptical about AI, I was also pretty turned off by AI's biggest cheerleaders, both on social media and in the world of VC funded startups. Not all of them, but a lot of them. Hopefully you won't make me elaborate.

And yet, a few weeks ago, I gave a talk at posit::conf—which is basically our Superbowl—about AI. I'm here giving a keynote about AI. And within Posit, I've personally spent countless hours providing my colleagues with the resources and encouragement they need to get up to speed on AI.

And to be clear, nobody is making me be here, nobody is making me focus this part of my career on AI, these are all choices I've made freely... but they've been pretty reluctant choices.

**So, what changed?**

Everybody I know who has any enthusiasm for modern AI, experienced an "a-ha" moment of some kind. Maybe they had a project where Claude unexpectedly saved them from a day of googling and Stack Overflow. Maybe they saw a social media post marveling at what the newest model du jour could do with a zero shot prompt.

In this talk, I want to share with you the three a-ha moments that shifted my thinking. Two of them were technical details of how Chat APIs work. One of them was a mindset shift, that I'll save to the end.

And along the way, we'll talk about new packages from Posit that will let you get started coding against chat APIs more easily than you would ever imagine.

## One: Anatomy of a Chat API call

The first a-ha moment was when I found out how chat APIs work. Like everyone a year ago, I'd tried ChatGPT. And like _almost_ everyone even now, I'd never made a chat API call.

What I expected was something like this:

```
start_conversation({system_prompt: "Be very terse and also casual"})
  <= {conversation_id: "b7ab8d8fe619a"}

send_message("b7ab8d8fe619a", {content: "Why is the sky blue?"})
  <= {content: "Rayleigh scattering, mostly"}

send_message("b7ab8d8fe619a", {content: "Not the ocean reflecting?"})
  <= {content: "Haha, nah"}

end_conversation("b7ab8d8fe619a")
  <= {}
```

But that's not how any of today's chat APIs actually work. Instead it's like this:

```
send({
  messages: [
    {role: "system", content: "Be very terse and also casual"},
    {role: "user", content: "Why is the sky blue?"}
  ]
})
  <= {role: "assistant", content: "Rayleigh scattering, mostly"}

send({
  messages: [
    {role: "system", content: "Be very terse and also casual"},
    {role: "user", content: "Why is the sky blue?"},
    {role: "assistant", content: "Rayleigh scattering, mostly"},
    {role: "user", content: "Not the ocean reflecting?"}
  ]
})
  <= {role: "assistant", content: "Haha, nah"}
```

It feels like you're having a back-and-forth discussion with this chat API. But the truth is, the chat API keeps no state on the server (other than how much money you owe them). As soon as it's done sending each response, it forgets it was ever talking to you!

So every _single_ time you need a chat API to respond to you, you need to bring it the _entire_ conversation up to that point. You, the client, are the only one keeping track of the conversation.

That actually felt freeing to me. Keeping track of the conversation is pretty easy, it's just a list of messages. And in return, the interface between client and server becomes dead simple: ask a question, get a response.

>  <u>Aside:</u> How does the assistant know it actually said what you are saying it said? It doesn't! What stops you from lying about the conversation history? Nothing! And in fact, sometimes that's a useful technique!

## Introducing {elmer}

Let's shift gears for a moment so I can tell you about a new package by Posit's own Hadley Wickham, called elmer. (LLM + R, get it? And also because it's glue code?)

Elmer is designed to make the above as simple as possible.

```
# Need OPENAI_API_KEY environment variable to be set

chat <- chat_openai(system_prompt = "Be very terse and also casual")
chat$chat("Why is the sky blue?")
chat$chat("Not the ocean reflecting?")
```

But this is actually not even the easiest way to use elmer. The easiest is `live_browser(chat)`...

[screen recording]

or `live_console(chat)`.

[screen recording]

Elmer chat objects automatically track the conversation for you. You can print the chat object at any time to see the conversation history.

If you want to start a new conversation, create a new chat object. If you want to fork an existing conversation, call `chat$clone()`.

### Why do this?

So far, we've just scratched the surface of both chat APIs and elmer, but I think there's already interesting things we can do with just this, versus using ChatGPT.

First, we have the ability to customize the **system prompt**. I've glossed over it so far, but the system prompt is the single most important thing to know about customizing chat models.

We can use the system prompt to direct the system's behavior.

```
"Be extremely terse"
"Tell me your plan of how to answer the question, then carry it out"
"You can give advice about coding, but refuse to actually write any sample code"
"Wrong answers only"
```

But we can take it much further than that.

```
"You are a sentiment classification model. Analyze each user prompt for between zero and three emotions that you would use to describe the author's state. Return a comma-separated list of these emotions, or the word 'None' if none can be inferred."
```

```
"You are a geolocator. Each user prompt will be a location of some kind; return the WGS84 latitude and logitude as a JSON array. For example: [42.3601, -71.0589]"
```


## 
## Project Setup Instructions

To get started with this project, follow these steps:

### 1. Install Elixir and Phoenix
Ensure that Elixir and the Phoenix framework are installed on your system. You can download and install Elixir from [Elixir's official website](https://elixir-lang.org/install.html) and follow the instructions to install Phoenix [here](https://hexdocs.pm/phoenix/installation.html).

### 2. Initialize the Project
Once Elixir and Phoenix are installed, you can set up the project dependencies. Run the following command in your terminal:

```bash
mix setup
```

## Database Seeding
For convenience, the setup includes seeding the database. It will create 10 users with predefined credentials. The users' emails will range from `email-0@cytely.com` to `email-9@cytely.com`, and all will have the password `password11234`


## Collaborative Editing in LiveView

For effective collaborative editing in LiveView, it is crucial to ensure that multiple users can work on the same plot without overwriting each other's changes. A recommended approach involves using a GenServer to manage editing sessions. This server will track which LiveView instance is currently editing the plot and prevent others from making concurrent edits, thus avoiding conflicts.

### Implementation Strategy

#### Locking Mechanism

- **GenServer Role**: Implement a GenServer that tracks the LiveView session currently editing a plot. The GenServer will manage a "lock" on the plot being edited.
- **Acquiring and Releasing Locks**:
  - **Acquire Lock**: When a user starts editing, the GenServer assigns a lock to their LiveView session, preventing other users from editing the same plot simultaneously.
  - **Release Lock**: The lock can be released in two ways:
    - **Automatic Release**: If the current editor becomes idle or completes their editing session, the GenServer will automatically release the lock.
    - **Manual Transfer**: The current editor has the option to manually transfer the lock to another specific user, facilitating controlled collaboration.

#### Handling Idle Sessions

- To enhance the system's robustness and user experience, implement a mechanism to detect idle users (e.g., no activity within a predefined timeout period).
- Once a user is identified as idle, the GenServer should automatically release the lock to allow other collaborators to continue working on the plot.

### Benefits

This approach not only prevents data loss from overwrites but also promotes a structured and harmonious collaborative environment. Users can work together seamlessly, with clear knowledge of who is currently editing and assurance that their contributions are safe.

### Conclusion

By leveraging Elixir's GenServer within a LiveView application, we can create a robust and user-friendly collaborative editing tool. This tool ensures that plot editing is both safe from conflicts and efficient in a multi-user environment.
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`


## Challenge in Advanced Expression Validation

The primary challenge encountered when dealing with advanced expressions is validation. The complexity of these expressions can significantly complicate the validation process.

## Proposed Solution: Extendable Validation Module/Library

Implementing an extendable validation module or even a dedicated library would streamline the validation process. This approach would simplify the task, especially when adding support for new literals, making the entire process more manageable and less time-consuming.

### Benefits

- **Simplicity**: The module/library abstracts the complexities of validating advanced expressions, making it simpler to integrate and use.
- **Extensibility**: It allows for easy expansion to include new literals and expression types without major alterations to the existing codebase.
- **Time Efficiency**: Reduces the development time needed when expanding support for new expressions, as the foundational validation logic is already in place.

### Conclusion

Creating a dedicated, extendable validation module or library for advanced expressions addresses the main challenges by providing a robust, scalable solution that can evolve with the needs of the system.



## Exploring Interactive Capabilities with Plotly and LiveView

Plotly is a robust tool for creating interactive plots, though I haven't fully explored its capabilities yet. It appears that we can enhance interactivity by leveraging both LiveView and JavaScript hooks to manage events. This method involves pushing events up from the client-side to LiveView and handling them accordingly, as well as responding with updates that can be propagated back to the client via JavaScript hooks. This bidirectional communication can significantly enrich the user experience by making the plots highly responsive and dynamic.

### Potential Enhancements

- **Event-Driven Updates**: Utilizing events to drive updates in real-time can make the interactive plots more engaging.
- **Dynamic Interactivity**: By handling events both on the server (LiveView) and the client (JavaScript), we can create a more seamless and interactive experience.

### Conclusion

Although my exploration of Plotly's full potential in this context is just beginning, the preliminary assessment suggests substantial possibilities for enhancing data visualization interactivity in applications that use LiveView and JavaScript.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

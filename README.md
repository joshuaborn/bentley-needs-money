[Bentley Needs Money](https://bentleyneeds.money) is an expense-sharing tool that helps people split and track expenses between them. It is named after Bentley the dog, as many of the expenses tracked relate to taking care of him. Bentley is known for his underbite, freckles, floppy ears, and being a very, very good boy.


### Technology

* [Ruby on Rails](https://rubyonrails.org/) (v7/8)
* [React](https://react.dev/)
* [TypeScript](https://www.typescriptlang.org/) via [Bun](https://bun.sh/)
* [PostgreSQL](https://www.postgresql.org/)
* [Docker](https://www.docker.com/)
* [DigitalOcean App Platform](https://www.digitalocean.com/products/app-platform)
* [Devise](https://github.com/heartcombo/devise)
* [Bulma](https://bulma.io/)


### Current Features

* Automatically splitting expenses in half between two people
* Calculating a running total of how much each person owes the other
* Tracking repayments between people
* Providing a mobile-friendly interface

### Planned Future Development

* You Need a Budget (YNAB) integration


### Data Model

* Person: The user model with Devise authentication that manages connections with other users and tracks financial relationships.
* Connection: Manages relationships between users, allowing them to share expenses.
* ConnectionRequest: Handles pending connections.
* SignupRequest: Invitations for non-users to join the system.
* Debt: The core financial record tracks money owed between people.
* Reason: Base class for financial events with associated debts.
  * Split: Subclass of Reason for splitting expenses, with logic for handling even/uneven splits.
  * Repayment: Subclass of Reason for tracking when someone pays back money.
  
The flow works like this: users connect through requests, connected users create splits for shared expenses, debts track money owed with running balances, and repayments settle those debts. The system maintains cumulative totals to track overall debt status between users.

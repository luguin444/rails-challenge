# Flatirons Development Back-end Rails Developer Coding Test

Be sure to read **all** of this document carefully, and follow the guidelines within.

## Context

Use Ruby On Rails to implement a pipeline to upload and process the following CSV file containing a list of products. The file could contain up to 100k rows.

## Requirements

1. The products should be stored along with multiple exchange rates at the time of the upload utilizing this [API](https://github.com/fawazahmed0/currency-api) (include at least 5 currencies, we should be able to add more currencies later on). There should be validations on the presence of fields.
2. There should be an index endpoint returning all the processed rows as well as all the available conversions that were stored at the time of the data intake.
3. There should be a way to filter and sort products

## Main Technologies

- Ruby ( version 3.0.6 );
- Rails ( version 7.1.4 );
- PostgreSQL;
- Rspec;
- Sidekiq;
- Redis

## How to run in development with containers?

To run this project in development, follow the steps below:

1. Ensure that docker and docker-compose are installed on your machine: Download here:

   - docker-compose: https://docs.docker.com/compose/install/
   - docker: https://www.docker.com/get-started/
   - Ubuntu: `sudo snap install docker`. To check, run: `docker -v` and `docker-compose -v`
     - Troubleshooting: If you have permissions problems, use `sudo` before the commands.

2. Clone the repository: `git clone <repository_url>`;

3. Create in the root directory the `.env.dockerfile` file based on the `.env.dockerfile` shared in the email;

4. Navigate to the project directory "rails_test-luisg" and run the following command to build and start the containers. `docker-compose up --build`

   - Troubleshooting: all ports must be free, otherwise the containers will not start. Maybe you must stop your local postgres or redis before step 4: `sudo service postgresql stop`. You can check the PORT=5432 with `sudo lsof -i :5432`

5. This will start with the server, PostgreSQL database, redis and sidekiq. You can verify this by running: `docker ps`

6. Manual tests can be conducted using the Postman software
   - Postman: grab a collection named `Rails Test.postman_collection.json` in the root of the project and load into the tool.

## How to run in development without containers?

1. Ensure that Ruby, Rails, Postgres and Redis are installed on your machine

To check, run: `ruby -v`, `rails -v`, `psql --version` and `redis-server --version`

2. Navigate to the project directory "rails_test-luisg" `cd rails_test-luisg/`

3. In the terminal, run `bundle install`

4. Create in the root directory the `.env file` based on the `.env` shared in the email;

   - Troubleshooting: you must use the user, password and port from the postgresql of your machine;

5. Create your development and test databases in your Postgres:

   - Development: `CREATE DATABASE development_products_api;`
   - Test: `CREATE DATABASE test_products_api;`

6. Run the server `rails server`.

   - Troubleshooting: If the containers are started, there will be conflict of ports. Stop them with: `docker-compose down`

## How to run the tests?

1. If you are running the application locally without containers, just run the command `bundle exec rspec` in the project directory. Make sure to have your test database created;

2. If you are using containers:

- Access the app container: `docker exec -it <container_name_from_server> bash`. To grab this name, just run `docker ps`
- Run the tests: `bundle exec rspec`

The tests will be printed !!

## API Documentation: https://www.notion.so/luguin444/Rails-Test-documentation-1162a646ef5280c38021d3a39c772f8d

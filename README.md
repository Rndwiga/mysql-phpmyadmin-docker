# MySQL Docker Setup with phpMyAdmin

This setup uses Docker Compose to create and run a MySQL database along with phpMyAdmin for easy management.

## Changes

The following changes were made to the initial setup:

* **phpMyAdmin Integration:** A new service for phpMyAdmin has been added to the `docker-compose.yml` file. This provides a web interface for managing the MySQL database.
* **Platform Specification:** The `platform: linux/amd64` line was added to the phpMyAdmin service in `docker-compose.yml`. This ensures that the correct image is used, especially on systems with different architectures (like ARM).
* **Environment Variable:** The `MYSQL_ROOT_PASSWORD` is now loaded from a `.env` file instead of being directly included in the `docker-compose.yml` file. This improves security by keeping the password out of the configuration file.

## Prerequisites

* Docker installed on your system.
* Docker Compose installed on your system.

## Setup

1.  **Create a `.env` file:** In the same directory as the `docker-compose.yml` file, create a file named `.env`.
2.  **Add MySQL root password to `.env`:** Add the following line to the `.env` file, replacing `your_mysql_root_password` with your desired password:

    ```
    MYSQL_ROOT_PASSWORD=your_mysql_root_password
    ```
3.  **Place the script:** Ensure the `install_and_run_mysql.sh` script is in the same directory as the `docker-compose.yml` file and the `.env` file.
4.  **Start the containers:** Open a terminal in the directory containing these files and run the following command:

    ```bash
    docker-compose up -d
    ```

    This will start the MySQL and phpMyAdmin containers in detached mode.
5.  **Access phpMyAdmin:** Once the containers are running, you can access phpMyAdmin in your web browser at `http://localhost:8080`.  Log in with the username `root` and the password you set in the `.env` file.
6. **Connect to MySQL:**
    * You can connect to the MySQL database from your host machine using a MySQL client and the root user with the password specified in the `.env` file.  The server address is `127.0.0.1` and the port is `3306`.

## Adding Additional Changes

If you need to customize the setup further, you can modify the following files:

* **`docker-compose.yml`:** This file defines the services (MySQL and phpMyAdmin) and their configuration.  You can change ports, add volumes, set environment variables, and define dependencies here.  For example:
    * To change the port where phpMyAdmin is accessible, modify the `ports` section of the `phpmyadmin` service.
    * To add more environment variables to the MySQL container, add them to the `environment` section of the `mysql` service (though sensitive variables should still be in the `.env` file).
* **`.env`:** This file stores environment variables, such as the MySQL root password.  You can add other sensitive configuration values here.
* **`install_and_run_mysql.sh`**: This script is executed within the docker container.

**Example: Changing the phpMyAdmin Port**

To change the port where phpMyAdmin is accessible to `8081`, modify the `docker-compose.yml` file as follows:

```yaml
version: '3.8'
services:
  mysql:
    # ... (mysql service definition remains the same)
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin
    platform: linux/amd64
    environment:
      PMA_HOST: mysql
      PMA_PORT: 3306
      PMA_USER: root
      PMA_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      UPLOAD_LIMIT: 2048M
    ports:
      - "8081:80"  # Change this line
    depends_on:
      - mysql
    restart: unless-stopped
volumes:
  mysql_data:
After making this change, run docker-compose up -d again
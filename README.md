# lift-jetty-cluster-aws
Sample Lift project that runs embedded Jetty in a cluster on AWS

## Running Locally
You can run this Lift project locally in development mode like any other Lift project with `sbt ~container:start`.
Clustering is configured in `bootstrap.liftweb.Start` which is only used when running stand-alone outside of sbt.
In stand-alone mode, clustering is configurable via Lift props files.

### MySQL Setup
To run the project standalone with clustering, you first need to configure MySQL locally.
Other DBs can be used if you prefer, as long as you accomplish the same tasks outlined below.

```text
mysql> create database lift_sessions;
Query OK, 1 row affected (0.02 sec)

mysql> create user 'jetty'@'localhost' identified by 'lift-rocks';
Query OK, 0 rows affected (0.02 sec)

mysql> grant all on lift_sessions.* TO 'jetty'@'localhost';
Query OK, 0 rows affected (0.00 sec)
```

You may use your own database name, user name, or password.
They can all be configured in `src/main/resources/props/default.props`.

### Building and Running
Build the application by running `sbt stage`.
This will produce a runnable script in `target/universal/stage/bin`.
Run the script.

### Observing How Jetty Utilizes SQL
Once the server boots, you can see jetty built two tables:
```text
mysql> use lift_sessions;
Database changed
mysql> show tables;
+-------------------------+
| Tables_in_lift_sessions |
+-------------------------+
| jettysessionids         |
| jettysessions           |
+-------------------------+
2 rows in set (0.00 sec)
```

Open your browser to `http://localhost:8080`.
Now you will see entries in the two tables.

```text
mysql> select * from jettysessionids;
+------------------------------------+
| id                                 |
+------------------------------------+
| B4LLKLNHFDomk1vhk5d9ow2rklylmi0gju |
+------------------------------------+
1 row in set (0.00 sec)
```

This is the `JSESSIONID` cookie value set in your browser.
(See for yourself in Chrome by looking on the _Resources_ tab in the _Developer Tools_)
The first 10 digits were created with `net.liftweb.util.StringHelpers.randomString` in `bootstrap.liftweb.Start`.
It is important that each Lift server instance sets this uniquely.
A second server with this same configuration (or a second _run_ of the same server) will prefix all of the cookies with a different random string.

## Running on AWS 
This project is designed to run in AWS.
Out of the box, it knows how to define it's entire infrastructure in a blank AWS region.

### Prerequisite: Key pair
If you do not already have a suitable key pair created in AWS, you will need to create one.
Go to the _EC2 Dashboard_ and find _Network & Security_ -> _Key Pairs_.
Click the _Create Key Pair_ button and enter "sandbox".
(You can name it differently, but you will need to modify the terraform files in this project to match.)
Save the downloaded `sandbox.pem` file somewhere safe.

If you already have a key pair, or you gave it a different name, then update the default value for `ec2_key_name` in `variables.tf`.

Convert the `sandbox.pem` private key into a public key:

```bash
ssh-keygen -y -f sandbox.pem > sandbox.pub
```

Save `sandbox.pub` in the `devops/` directory.
With this key pair, you will be able to SSH into your EC2 instances running Lift.

### Environment
The `deploy.sh` script needs to run in a unix environment with the following variables set:
`AWS_ACCESS_KEY_ID`
`AWS_SECRET_ACCESS_KEY`
`TF_STATE_BUCKET`: The S3 bucket where you want to store the Terraform state.
`TF_STATE_KEY`: The S3 key within the bucket where you want to store the Terraform state.
`DB_USERNAME`: The username you want for the RDS MySQL DB we build.
`DB_PASSWORD`: The password you want for the RDS MySQL DB we build.

I recommend using [Codeship](http://codeship.io) as your CI for running Terraform, as that is where this has been tested.
It is 100% free to use (up to a certain number of builds per month).

## TODO

* Rename `sandbox.pub`
* Load balance multiple Lift instances
* Enable cluster in AWS
* Heroku deployment
* Package `webapp` into jar file

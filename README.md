# lift-jetty-cluster
Sample Lift project that runs embedded Jetty in a cluster.

Jetty implements clustering by serializing the container session object into a SQL database.
Each Jetty instance creates `JSESSIONID` cookies with an instance-identifying string (in this project, we create a randomly-generated string at startup time).
When an instance receives a request with a `JESSIONID` it doesn't recongnize, it will look it up in the SQL store.

This sample app takes advantage of Lift's [`ContainerVar`](http://timperrett.com/2010/11/18/meet-lifts-containerva/).
They work just like Lift's `SessionVar`, except that the values are stored in the container's session rather than Lift's session.
Coupled with a clustered container, this allows the `ContainerVar` values to survive container instance failures.

This project has all you need to run Lift in this configuration locally, on Heroku, or on AWS.

AWS status: [ ![Codeship Status for joescii/lift-jetty-cluster](https://codeship.com/projects/c0e8eac0-2c0b-0133-b2b8-16bcb9ef4133/status?branch=aws)](https://codeship.com/projects/98491)

Heroku status: [ ![Codeship Status for joescii/lift-jetty-cluster](https://codeship.com/projects/c0e8eac0-2c0b-0133-b2b8-16bcb9ef4133/status?branch=heroku)](https://codeship.com/projects/98491)

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Running Locally
You can run this Lift project locally in development mode like any other Lift project with `sbt ~container:start`.
Clustering is configured in `bootstrap.liftweb.Start` which is only used when running outside of sbt.
Enable clustering in the appropriate Lift props file for your run mode.

### MySQL Setup
To run the project standalone with clustering, you first need to configure MySQL locally.
Other SQL DBs can be used if you prefer, as long as you accomplish the same tasks outlined below.
Namely, you need a user named `jetty` with password `lift-rocks` with all permissions granted on a DB named `lift_sessions`.

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
Once the server boots, the curious developer can see jetty built two tables:
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

## Deploying to Heroku
If not using the _Deploy to Heroku_ button [above](#lift-jetty-cluster), you simply need to run these commands:

```shell
$ heroku create [optional_app_name]
$ heroku addons:create cleardb
$ git push heroku master
```

Once you are ready to run multiple instances of Lift, you need to enable [session affinity](https://blog.heroku.com/archives/2015/4/28/introducing_session_affinity) and bump up the number of web workers:

```shell
$ heroku labs:enable http-session-affinity
$ heroku ps:scale web=2
```

## Deploying to AWS 
This project includes everything you need to deploy in AWS.
Out of the box, it knows how to define it's entire infrastructure in a blank AWS region.

### Prerequisite: Key pair
If you do not already have a suitable key pair created in AWS, you will need to create one.
Go to the _EC2 Dashboard_ and find _Network & Security_ -> _Key Pairs_.
Click the _Create Key Pair_ button and enter "sandbox".
(You can name it differently, but you will need to modify the `ec2_key_name` variable in `aws/variables.tf` in this project to match.)
Save the downloaded `sandbox.pem` file somewhere safe.

If you already have a key pair, or you gave it a different name, then update the default value for `ec2_key_name` in `aws/variables.tf`.

Convert the `sandbox.pem` private key into a public key:

```bash
ssh-keygen -y -f sandbox.pem > ssh-key.pub
```

Save and commit `ssh-key.pub` into the `aws/` directory.
With this key pair, you will be able to SSH into your EC2 instances running Lift as the `lift` user.

### Environment
The `deploy.sh` script needs to run in a unix environment with the following variables set:
* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `TF_STATE_BUCKET`: The S3 bucket where you want to store the Terraform state.
* `TF_STATE_KEY`: The S3 key within the bucket where you want to store the Terraform state.
* `DB_USERNAME`: The username you want for the RDS MySQL DB we build.
* `DB_PASSWORD`: The password you want for the RDS MySQL DB we build.
* `PRIVATE_KEY`: The private SSH key copied out of the file and pasted into this variable.
(kinda hacky, but it's the simplest way I found to have a private key which is not in this public repo)

The `env.sh` script will download [terraform](https://terraform.io/) and [packer](https://www.packer.io/) and place them on your `$PATH`.
It will NOT set up java on your local system, which is a prerequisite for [sbt](http://www.scala-sbt.org/).
The `codeship.sh` script wraps up `env.sh` and `deploy.sh` together for use in [Codeship](http://codeship.io).
I recommend using [Codeship](http://codeship.io) as your CI at least for a starting point, as that is where all of this has been tested.
It is 100% free to use (up to a certain number of builds per month).

### Terraform Bug Workaround
Currently there is [a bug in Terraform](https://github.com/hashicorp/terraform/issues/3125) which this project exposes.
Upon your first run of `deploy.sh`, you will get a failure like the following:

```text
* aws_launch_configuration.lift_as_conf: diffs didn't match during apply. This is a bug with Terraform and should be reported.
```

The workaround is to find the AMI ID created by Packer.
The output will look something like the following:

```text
Produced AMI at ami-5153a915
```

Open `aws/aws-ec2.tf`.
Find `resource "template_file" "packer"`.
In that object, replace `ami = "${file(var.ami_txt)}"` with the AMI ID from the packer output.
For instance, given the above AMI ID, you would change this line to `ami = "ami-5153a915"`.

Go down a few more lines in `aws/aws-ec2.tf` and find `resource "template_file" "packer_runner"`.
In that object, remove these three lines:

```text
provisioner "local-exec" {
  command = "./bake.sh ${var.access_key} ${var.secret_key} ${module.region.region} ${module.vpc.vpc_id} ${module.vpc.zone_B_public_id} ${module.vpc.packer_sg_id} ${module.region.ubuntu_precise_12_04_amd64} ${var.db_password} ${var.timestamp}"
}
```

Run `deploy.sh` again.
It should succeed this time.
Restore `aws/aws-ec2.tf` back to its original state.
Terraform/Packer will happily run from now on.

## TODO

* Log to S3 or something like that
* Add self-downloading sbt script
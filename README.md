This is example project for blog post: << link >>

It contains two State Machines where second one is started from within first one. First State Machine then waits until second State Machine is completed. It is achieved without active polling by making use of Activities and smart handling of a Task Token.

### Requirements

* Terraform
* zip command
* bash shell

### Deployment

**Note: Deploying this example may cost you money. However for simple deployment and single run of the State Machine the cost should be negligible.**

Run following command:
```
terraform apply
```

You should have defined `AWS_REGION` and `AWS_PROFILE` environment variables defined. Instead of `AWS_PROFILE` you could also specify `AWS_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY`.

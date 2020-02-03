#!/bin/bash

cat <<'EOF' > credential_tmp.xml
<com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
          <scope>GLOBAL</scope>
          <id>ssh-example</id>
          <description></description>
          <username>jenkins</username>
          <privateKeySource class="com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource">
          <privateKey>
EOF

cat credential_tmp.xml /var/lib/jenkins/.ssh/id_rsa > credential.xml

cat <<'EOF' >> credential.xml
        </privateKey>
          </privateKeySource>
        </com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
EOF

ADMIN_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)

JENKINS_CRUMB=$(curl -u "admin:${ADMIN_PASSWORD}" 'http://localhost:8080/crumbIssuer/api/json' | jq -r ".crumb")

JENKINS_CRUMB=$(echo ${JENKINS_CRUMB} | cut -f2 -d:)

curl -X POST \
  -u "admin:${ADMIN_PASSWORD}" \
  -H "Jenkins-Crumb:${JENKINS_CRUMB}" \
  -H 'content-type:application/xml' \
  -d @credential.xml \
"http://localhost:8080/credentials/store/system/domain/_/createCredentials"

# Create a new worker that uses the above credential

curl -L -v -X POST \
  -u "admin:${ADMIN_PASSWORD}" \
  -H "Jenkins-Crumb:${JENKINS_CRUMB}" \
  -H "Content-Type:application/x-www-form-urlencoded" \
  "http://localhost:8080/computer/doCreateItem?name=jenkins-worker&_.nodeDescription=&_.numExecutors=1&_.remoteFS=%2Fhome%2Fjenkins%2Fjenkins&_.labelString=jenkins-worker&mode=EXCLUSIVE&stapler-class=hudson.slaves.CommandLauncher&%24class=hudson.slaves.CommandLauncher&_.command=&stapler-class=hudson.plugins.sshslaves.SSHLauncher&%24class=hudson.plugins.sshslaves.SSHLauncher&_.host=10.0.0.15&includeUser=false&_.credentialsId=ssh-example&stapler-class=hudson.plugins.sshslaves.verifiers.KnownHostsFileKeyVerificationStrategy&%24class=hudson.plugins.sshslaves.verifiers.KnownHostsFileKeyVerificationStrategy&stapler-class=hudson.plugins.sshslaves.verifiers.ManuallyProvidedKeyVerificationStrategy&%24class=hudson.plugins.sshslaves.verifiers.ManuallyProvidedKeyVerificationStrategy&stapler-class=hudson.plugins.sshslaves.verifiers.ManuallyTrustedKeyVerificationStrategy&%24class=hudson.plugins.sshslaves.verifiers.ManuallyTrustedKeyVerificationStrategy&stapler-class=hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy&%24class=hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy&_.port=22&_.javaPath=&_.jvmOptions=&_.prefixStartSlaveCmd=&_.suffixStartSlaveCmd=&launchTimeoutSeconds=&maxNumRetries=&retryWaitTime=&tcpNoDelay=on&workDir=&stapler-class=hudson.slaves.RetentionStrategy%24Always&%24class=hudson.slaves.RetentionStrategy%24Always&stapler-class=hudson.slaves.SimpleScheduledRetentionStrategy&%24class=hudson.slaves.SimpleScheduledRetentionStrategy&retentionStrategy.startTimeSpec=&retentionStrategy.upTimeMins=&retentionStrategy.keepUpWhenActive=on&stapler-class=hudson.slaves.RetentionStrategy%24Demand&%24class=hudson.slaves.RetentionStrategy%24Demand&retentionStrategy.inDemandDelay=&retentionStrategy.idleDelay=&stapler-class-bag=true&type=hudson.slaves.DumbSlave&json=%7B%22name%22%3A+%22jenkins-worker%22%2C+%22nodeDescription%22%3A+%22%22%2C+%22numExecutors%22%3A+%221%22%2C+%22remoteFS%22%3A+%22%2Fhome%2Fjenkins%2Fjenkins%22%2C+%22labelString%22%3A+%22jenkins-worker%22%2C+%22mode%22%3A+%22EXCLUSIVE%22%2C+%22%22%3A+%5B%22hudson.plugins.sshslaves.SSHLauncher%22%2C+%22hudson.slaves.RetentionStrategy%24Always%22%5D%2C+%22launcher%22%3A+%7B%22stapler-class%22%3A+%22hudson.plugins.sshslaves.SSHLauncher%22%2C+%22%24class%22%3A+%22hudson.plugins.sshslaves.SSHLauncher%22%2C+%22host%22%3A+%2210.0.0.15%22%2C+%22includeUser%22%3A+%22false%22%2C+%22credentialsId%22%3A+%22ssh-example%22%2C+%22%22%3A+%223%22%2C+%22sshHostKeyVerificationStrategy%22%3A+%7B%22stapler-class%22%3A+%22hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy%22%2C+%22%24class%22%3A+%22hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy%22%7D%2C+%22port%22%3A+%2222%22%2C+%22javaPath%22%3A+%22%22%2C+%22jvmOptions%22%3A+%22%22%2C+%22prefixStartSlaveCmd%22%3A+%22%22%2C+%22suffixStartSlaveCmd%22%3A+%22%22%2C+%22launchTimeoutSeconds%22%3A+%22%22%2C+%22maxNumRetries%22%3A+%22%22%2C+%22retryWaitTime%22%3A+%22%22%2C+%22tcpNoDelay%22%3A+true%2C+%22workDir%22%3A+%22%22%7D%2C+%22retentionStrategy%22%3A+%7B%22stapler-class%22%3A+%22hudson.slaves.RetentionStrategy%24Always%22%2C+%22%24class%22%3A+%22hudson.slaves.RetentionStrategy%24Always%22%7D%2C+%22nodeProperties%22%3A+%7B%22stapler-class-bag%22%3A+%22true%22%7D%2C+%22type%22%3A+%22hudson.slaves.DumbSlave%22%2C+%7D&Submit=Save"

# Apply Job Configurations - access-secret

cat <<'EOF' > job2_config.xml
<flow-definition plugin="workflow-job@2.36">
<description/>
<keepDependencies>false</keepDependencies>
<properties>
<hudson.model.ParametersDefinitionProperty>
<parameterDefinitions>
<hudson.model.StringParameterDefinition>
<name>roleId</name>
<description>
An existing role ID. To be used in conjunction with existing-unwrapping-token parameter
</description>
<defaultValue/>
<trim>false</trim>
</hudson.model.StringParameterDefinition>
<hudson.model.StringParameterDefinition>
<name>wrappingToken</name>
<description>
An existing unwrapping token. Enter this parameter to demonstrate what happens if the process has been compromised
</description>
<defaultValue/>
<trim>false</trim>
</hudson.model.StringParameterDefinition>
</parameterDefinitions>
</hudson.model.ParametersDefinitionProperty>
</properties>
<definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.78">
<script>
// Create a pipeline job called access-secret with two parameters as defined below

def secretId = 'initial_value'
def token    = 'initial_value'
def secret   = 'initial_value'

pipeline {
  agent {
    label 'jenkins-worker'
  }
  parameters {
    string(name: 'roleId', description: 'An existing role ID. To be used in conjunction with existing-unwrapping-token parameter')
    string(name: 'wrappingToken', description: 'An existing unwrapping token. Enter this parameter to demonstrate what happens if the process has been compromised')
  }

  stages {
    stage('unwrap-secretId') {
      steps {
        echo 'Attempting to unwrap secret ID from wrapping token'
        script{
          secretId = sh(script: "export VAULT_ADDR=http://10.0.0.10:8200; VAULT_TOKEN=$wrappingToken vault unwrap | grep secret | grep -v accessor | cut -f14 -d' '", returnStdout: true).trim()
        }
      }
    }

    stage('access-secret') {
      steps {
        echo 'Logging in to Vault...'
        script {
          token = sh(script: "export VAULT_ADDR=http://10.0.0.10:8200; vault write auth/approle/login role_id=$roleId secret_id=$secretId | grep token | grep -v _ | cut -f20 -d' '", returnStdout: true).trim()
        }
        echo 'Accessing secret...'
        script {
          secret = sh(script: "export VAULT_ADDR=http://10.0.0.10:8200; VAULT_TOKEN=$token vault read secret/data/dev", returnStdout: true).trim()
        }
        echo "${secret}"
      }
    }
  }
}

</script>
<sandbox>true</sandbox>
</definition>
<triggers/>
<disabled>false</disabled>
</flow-definition>
EOF

curl -v -X POST \
  -u "admin:${ADMIN_PASSWORD}" \
  -H "Jenkins-Crumb:${JENKINS_CRUMB}" \
  -H "Content-Type:text/xml" \
  --data-binary @job2_config.xml \
'http://localhost:8080/createItem?name=access-secret'

# Apply Job Configuration - create-wrapped-secret-id

cat <<'EOF' > job1_config.xml
<flow-definition plugin="workflow-job@2.36">
<description/>
<keepDependencies>false</keepDependencies>
<properties/>
<definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.78">
<script>
// Create a pipeline job called create-wrapped-secret-id

def roleId         = 'initial_value'
def wrappingToken  = 'initial_value'

pipeline {
  agent {
    label 'master'
  }
  stages {
    stage('get-wrapped-secret-id') {

      steps {
        echo 'Attempting to create wrapped secret id'
        echo roleId // prints initial value of roleId
        script {
          roleId = sh(script: 'export VAULT_ADDR=http://10.0.0.10:8200; vault login $(cat /tmp/token) > /dev/null 2>&amp;1; vault read auth/approle/role/app1/role-id | grep role_id | cut -f5 -d" "', returnStdout: true).trim()
          wrappingToken = sh(script: 'export VAULT_ADDR=http://10.0.0.10:8200; vault login $(cat /tmp/token) > /dev/null 2>&amp;1; vault write -wrap-ttl=60m -f auth/approle/role/app1/secret-id  | grep wrapping_token | cut -f19 -d" "', returnStdout: true).trim()
        }
      }
    }

    stage('access-secret') {
      steps {
        echo 'Building next job...'
        build job: 'access-secret', parameters: [[$class: 'StringParameterValue', name: 'roleId', value: roleId],
                                                  [$class: 'StringParameterValue', name: 'wrappingToken', value: wrappingToken]]
      }
    }
  }
}

</script>
<sandbox>true</sandbox>
</definition>
<triggers/>
<disabled>false</disabled>
</flow-definition>
EOF

curl -v -X POST \
  -u "admin:${ADMIN_PASSWORD}" \
  -H "Jenkins-Crumb:${JENKINS_CRUMB}" \
  -H "Content-Type:text/xml" \
  --data-binary @job1_config.xml \
'http://localhost:8080/createItem?name=create-wrapped-secret-id'

import subprocess
from faker import Faker
import random
import argparse

# Initialize Faker
fake = Faker()

def user_exists(username):
    # PowerShell command to check if a user exists
    command = f"Get-LocalUser -Name \"{username}\""
    result = subprocess.run(["powershell", "-Command", command], capture_output=True, text=True)
    return result.returncode == 0

def create_user(username, password):
    # Escape special characters in the password
    password = password.replace('"', '`"').replace("'", "''").replace('$', '`$').replace('(', '`(').replace(')', '`)').replace(';', '`;')
    
    # PowerShell commands to create a new user
    commands = [
        f"$username = \"{username}\"",
        f"$password = ConvertTo-SecureString \"{password}\" -AsPlainText -Force",
        "$user = New-LocalUser -Name $username -Password $password -FullName $username -Description \"Generated User\"",
        "Add-LocalGroupMember -Group \"Users\" -Member $username"
    ]
    
    # Combine commands into a single string separated by semicolons
    command = ";".join(commands)
    
    print("Command to execute:", command)  # Print the command before execution
    
    # Run the PowerShell command
    subprocess.run(["powershell", "-Command", command], check=True)

def add_admin_privileges(username):
    # PowerShell command to add a user to the Administrators group
    command = f"Add-LocalGroupMember -Group \"Administrators\" -Member \"{username}\""
    
    # Run the PowerShell command
    subprocess.run(["powershell", "-Command", command], check=True)

def generate_valid_password():
    while True:
        password = fake.password(length=12)
        # Avoid passwords that contain problematic characters
        if all(c not in password for c in ['$','(',')',';']) and password:  
            return password

def generate_unique_username(checked_usernames):
    while True:
        username = fake.user_name()[:20]  # Ensure username is no longer than 20 characters
        if username not in checked_usernames:
            if not user_exists(username):
                return username
            checked_usernames.add(username)

def main(num_users):
    users = []
    checked_usernames = set()  # Keep track of checked usernames

    for i in range(1, num_users + 1):
        # Generate unique username and valid password
        username = generate_unique_username(checked_usernames)
        password = generate_valid_password()
        
        # Create the user account
        create_user(username, password)
        
        # Keep track of created users
        users.append(username)
        
        # Print the current number of each user being added
        print(f"Added user {i}/{num_users}: {username}")

        # 1 in 10 chance to give the user admin privileges
        if random.randint(1, 10) == 1:
            add_admin_privileges(username)
            print(f"User {username} was given administrative privileges.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Create users and assign administrative privileges to some users.")
    parser.add_argument("-n", "--num_users", type=int, default=5, help="Number of users to create (default is 5)")
    args = parser.parse_args()

    if args.num_users == 5:
        print("No --num_users parameter specified. Defaulting to 5 users.")
    else:
        print(f"Creating {args.num_users} users.")
    
    print("To specify the number of users, use the command line: python script_name.py --num_users <number_of_users>")

    main(args.num_users)

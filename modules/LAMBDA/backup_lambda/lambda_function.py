import os

def lambda_handler(event, context):
    # Get the environment and file path from environment variables
    environment = os.getenv('ENVIRONMENT', 'dev').lower()  # Default to 'dev' if not set
    file_path = os.getenv('FILE_PATH', '/mnt/efs/nats.config')
    directory = os.path.dirname(file_path) # extract dir path
    cluster_ips = os.getenv('CLUSTER_IPS', '').split(',')  # Split the comma-separated IPs
    # Check permissions and ownership
    try:
        directory_stats = os.stat(directory)
        permissions = oct(directory_stats.st_mode)[-3:]  # e.g., 777
        owner_uid = directory_stats.st_uid  # User ID
        owner_gid = directory_stats.st_gid  # Group ID

        print(f"Directory permissions: {permissions}")
        print(f"Owner UID: {owner_uid}, GID: {owner_gid}")
    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"Failed to check directory permissions: {str(e)}"
        }
    # Check if we should include the cluster section
    if environment != "dev" and cluster_ips:
        cluster_config = f""" 
        cluster {{
          name: "JSC"
          listen: "0.0.0.0:4245"
          routes = {cluster_ips}
        }}
        """
    else:
        cluster_config = ""

    # Define the rest of the NATS config content
    nats_config_content = f"""
    port: 4222
    max_payload: 8388608

    websocket {{
      port: 8222
      no_tls: true
    }}
    
    {cluster_config}

    authorization {{
      users = [
        {{ nkey: "UCLWSLILGU7BBCLY3UDB7WG5AVQJJFNEXWJBQ2ORZSU55ETHSTVDK7E2" }},
        {{ nkey: "UB367CDFPLUDAMTH3A4HHWNG6FN5EG7L7RTVEQ7D4JW7QK5A5X2ZCWUW" }},
        {{ nkey: "UBN4ZZGPVKY7G47AHN7CC5BSKYK3F3IWPZCMEKMHEWYY7QDENLEZV2BE" }},
        {{ nkey: "UALNVHD4QE6NT5JTEQEJNQVY6X5G4UHBQK7LSHKVVJQTTPGAVUEA27UX" }},
        {{ nkey: "UD7S64U6XNPZAQATWFZIEBPR22Z3QV4RPG7AL65EJ5GTRSIHVZQKWSQS" }},
        {{ nkey: "UBV7LBXFDYAQD6B7AZLHMG2HKNWUMK2EFSB3ESIYB5CX5R4OFZKW5ADD" }},
        {{ nkey: "UDEAKKZ6KUOZL67GETYI636JQSWXF4MF4DJZLTHTJMQ5YOTI3NHIBRWO" }},
        {{ nkey: "UC32LZ2K2KK2NEISLT7BAAHKUYRSLBYSGRENGLGUTF2H22J54XRBRPEP" }},
        {{ nkey: "UAMW3BUSV2FZU2Z7PG5DN4LS2TGHBINMP6TR6NVPTQRAWRPMFSKXGN2E" }},
        {{ nkey: "UBRIT74BU5HAX6DFHJ3B4KFV2SBJJIWJRPJTUFA5CNQDR7X2OFPQN5IN" }},
        {{ nkey: "UDDVCLXNCCVLKYJ4EZIYJR3OG7K534KBYD3ZOLDCTGJDEQQDTDJYO7AO" }},
        {{ nkey: "UC22WIJ7Z6GREOYMTUMBK3BRCCPQM23RZKZ5QTX5RAUUZZUBMBVYJB4L" }},
        {{ nkey: "UALIW4SXM2GTHWGVWMT3MGL64AVC6GHFGZESJUJDGU32F5TX7RXJ62E7" }},
        {{ nkey: "UBH7N6LUIYVC6FAAR4EVEEM34JST4SERXCEL2XJIZHQLJQ6MIJWXNZ2K" }},
        {{ nkey: "UDMEXFPSNFMATTDYLSZ4CEZMWUZY7BB4RG2JCD3UNUPNBONH5EP5JXCF" }},
        {{ nkey: "UB4IOIHOJRVBKATMMASMKVQLBXUC4O6UE4NRJBWWYWKX6ZBOSEFHVO4D" }},
        {{ nkey: "UALOIUDMMAAIOHULEQBKVJXSOIVHNSEXWVQIHJPFBEBKMKMX73KXQRLG" }}
      ]
    }}
    """

    # Write the content to the file in EFS
    try:
        with open(file_path, "w") as config_file:
            config_file.write(nats_config_content)
        return {
            "statusCode": 200,
            "body": f"nats.config file created successfully at {file_path}"
        }
    except PermissionError:
        return {
            "statusCode": 403,
            "body": "Permission denied: Lambda does not have write access to the directory."
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"Failed to create nats.config: {str(e)}"
        }

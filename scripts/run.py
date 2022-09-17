def run(nre):
    # Nous compilons notre contract
    print("Compiling contract")
    nre.compile(["contracts/ExyNFT.cairo"])
    print("Deploying contract")
    # Déclaration de nos variables que l'on passe dans la fonction str_to_felt, hex_to_felt, str_to_felt_array
    name = str_to_felt("ExyNFT")
    symbol = str_to_felt("EXY")
    owner = hex_to_felt("0x04a71727f73352b28C2D2f29fD8038d01b0E14b66660e8fa9b08535535bd7F3e")
    # Création d'un tableau composé de 3 elements
    tokenuri = str_to_felt_array("https://gateway.pinata.cloud/ipfs/QmZKnEaehsYUCvyKhdSjWwWryAMJQQCo7w1qpY8BZT8cHn/")
    end_uri = str_to_felt(".json") # l'extension de notre url, ici .json
    # length de notre tableau tokenuri (3)
    lengthtokenuri = len(tokenuri)
    
    params = [
        name, # ExyNFT = 76383733565012
        symbol, # EXY = 4544601
        owner, #0x04a71727f73352b28C2D2f29fD8038d01b0E14b66660e8fa9b08535535bd7F3e = 2104474671788201053296096743643013776942140027118769188972086267638687039294
        lengthtokenuri, # 3 
        *tokenuri, # https://gateway.pinata.cloud/ipfs/QmZKnEaehsYUCvyKhdSjWwWryAMJQQCo7w1qpY8BZT8cHn = 184555836509371486644298270517380613565396767415278678887948391494588524912, 181013377130050194783707620816167369024040746088578005820478819159905488202, 1813439402992338140695324051692374467063344687
        end_uri, # .json = 199354445678
    ]
    print(params)
    address, abi = nre.deploy("ExyNFT", params, alias="exy_nft")

    print(f"ABI : {abi},\ExyNFT address : {address}")

# Nos utils sont ici directement, il est bien entendu possible de mettres dans un autre fichier puis les importer mais j'ai
# Eu quelques soucis d'import ce pourquoi je les mets la
MAX_LEN_FELT = 31


def str_to_felt(text):
    if len(text) > MAX_LEN_FELT:
        raise Exception("Text length too long to convert to felt.")

    return int.from_bytes(text.encode(), "big")


def felt_to_str(felt):
    length = (felt.bit_length() + 7) // 8
    return felt.to_bytes(length, byteorder="big").decode("utf-8")


def str_to_felt_array(text):
    return [str_to_felt(text[i:i+MAX_LEN_FELT]) for i in range(0, len(text), MAX_LEN_FELT)]


def uint256_to_int(uint256):
    return uint256[0] + uint256[1]*2**128


def uint256(val):
    return (val & 2**128-1, (val & (2**256-2**128)) >> 128)


def hex_to_felt(val):
    return int(val, 16)

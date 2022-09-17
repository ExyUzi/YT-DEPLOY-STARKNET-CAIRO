%lang starknet
// Import des différentes librairies, grâce à openzeppelin / dossier contracts en local / starkware
// Ces librairies vont nous servires à différentes choses, récuperer l'adresse de la personne appelant la fonction, ERC721, Ownable...
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.token.erc721.library import ERC721
from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.access.ownable.library import Ownable

from contracts.token.ERC721.ERC721_Metadata_base import (
    ERC721_Metadata_initializer,
    ERC721_Metadata_tokenURI,
    ERC721_Metadata_setBaseTokenURI,
)

@storage_var
func next_token() -> (token_id: Uint256) {
}
//
// Constructor
//

// Ici nous avons un constructeur que nous allons devoir renseigné lors du déploiement, comme en solidity
// felt en cairo = field element, le type primaire de données en cairo https://www.cairo-lang.org/docs/hello_cairo/intro.html pour plus d'informations

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    name: felt,
    symbol: felt,
    owner: felt,
    base_token_uri_len: felt,
    base_token_uri: felt*,
    token_uri_suffix: felt,
) {
    ERC721.initializer(name, symbol);
    ERC721_Metadata_initializer();
    Ownable.initializer(owner);
    ERC721_Metadata_setBaseTokenURI(base_token_uri_len, base_token_uri, token_uri_suffix);
    next_token.write(Uint256(1, 0));
    return ();
}

//
// Getters
//
// Getters classiques, avec une valeure retournée
@view
func getOwner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt) {
    let (owner) = Ownable.owner();
    return (owner=owner);
}

@view
func supportsInterface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    interface_id: felt
) -> (success: felt) {
    let (success) = ERC165.supports_interface(interface_id);
    return (success,);
}
// Etudions ce getter ci, nous allons récupérer le nom de notre ERC721, initialisé  ligne 32 et le retourner
@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    let (name) = ERC721.name();
    return (name,);
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    let (symbol) = ERC721.symbol();
    return (symbol,);
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) -> (
    balance: Uint256
) {
    let (balance: Uint256) = ERC721.balance_of(owner);
    return (balance,);
}

@view
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (owner: felt) {
    let (owner: felt) = ERC721.owner_of(token_id);
    return (owner,);
}

@view
func getApproved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (approved: felt) {
    let (approved: felt) = ERC721.get_approved(token_id);
    return (approved,);
}

@view
func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, operator: felt
) -> (is_approved: felt) {
    let (is_approved: felt) = ERC721.is_approved_for_all(owner, operator);
    return (is_approved,);
}

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (token_uri_len: felt, token_uri: felt*) {
    let (token_uri_len, token_uri) = ERC721_Metadata_tokenURI(token_id);
    return (token_uri_len=token_uri_len, token_uri=token_uri);
}

//
// Externals
//

@external
func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, token_id: Uint256
) {
    ERC721.approve(to, token_id);
    return ();
}

@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    operator: felt, approved: felt
) {
    ERC721.set_approval_for_all(operator, approved);
    return ();
}

@external
func transferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, to: felt, token_id: Uint256
) {
    ERC721.transfer_from(_from, to, token_id);
    return ();
}

@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, to: felt, token_id: Uint256, data_len: felt, data: felt*
) {
    ERC721.safe_transfer_from(_from, to, token_id, data_len, data);
    return ();
}

@external
func setTokenURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    base_token_uri_len: felt, base_token_uri: felt*, token_uri_suffix: felt
) {
    // OnlyOwner en solidity, uniquement l'owner du contract peut appeler ce setter
    Ownable.assert_only_owner();
    ERC721_Metadata_setBaseTokenURI(base_token_uri_len, base_token_uri, token_uri_suffix);
    return ();
}

@external
func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() {
    // Nous récupérons l'adress du caller de la fonction
    let (caller_address) = get_caller_address();
    // Nous récupérons l'id next_token (storage_var)
    let (tokenId: Uint256) = next_token.read();
    // Mint du token au caller
    ERC721._mint(caller_address, tokenId);
    let (next_tokenId, _) = uint256_add(tokenId, Uint256(1, 0));
    // Incrémentation du next_tokenId
    next_token.write(next_tokenId);
    return ();
}

@external
func burn{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(token_id: Uint256) {
    Ownable.assert_only_owner();
    ERC721._burn(token_id);
    return ();
}

@external
func transferOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    new_owner: felt
) -> (new_owner: felt) {
    // Ownership check is handled by this function
    Ownable.transfer_ownership(new_owner);
    return (new_owner=new_owner);
}
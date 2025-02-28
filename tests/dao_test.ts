// ... [Previous tests] ...

Clarinet.test({
  name: "Test token-weighted voting system",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const wallet_1 = accounts.get("wallet_1")!;
    const wallet_2 = accounts.get("wallet_2")!;
    
    // Mint tokens
    let block = chain.mineBlock([
      Tx.contractCall("dao-token", "mint", [
        types.uint(1000),
        types.principal(wallet_1.address)
      ], deployer.address),
      Tx.contractCall("dao-token", "mint", [
        types.uint(500),
        types.principal(wallet_2.address)
      ], deployer.address)
    ]);
    
    // Submit proposal
    block = chain.mineBlock([
      Tx.contractCall("impact-dao", "submit-proposal", [
        types.ascii("Test Proposal"),
        types.utf8("Description"),
        types.uint(1000),
        types.principal(wallet_1.address)
      ], wallet_1.address)
    ]);
    
    // Vote with different weights
    block = chain.mineBlock([
      Tx.contractCall("impact-dao", "vote", [
        types.uint(1),
        types.bool(true)
      ], wallet_1.address),
      Tx.contractCall("impact-dao", "vote", [
        types.uint(1),
        types.bool(false)
      ], wallet_2.address)
    ]);
    
    // Verify vote weights
    const proposal = chain.callReadOnlyFn(
      "impact-dao",
      "get-proposal",
      [types.uint(1)],
      deployer.address
    );
    
    assertEquals(proposal.result.expectSome().votes_for, 1000);
    assertEquals(proposal.result.expectSome().votes_against, 500);
  },
});

// ... [Additional new tests] ...

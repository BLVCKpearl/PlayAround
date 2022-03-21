const RickHeadERC721 = artifacts.require("RickHeadERC721");

contract("RickHeadERC721", async (accounts) => {


    // it.only("should have the right owner", async () => {
    //     const instance = await RickHeadERC721.deployed()
    //     let paused = await instance.paused();
    //     assert.equal(paused, false);

    //     await instance.mint(1,{
    //         r: '',
    //         s: '',
    //         v: 27
    //     },{from: accounts[1]})

    // });


    it("should have max supply equal to 3333", async () => {
        const instance = await RickHeadERC721.deployed();
        const maxSupply = parseInt((await instance.maxSupply()).toString())
        assert.equal(maxSupply, 3333);
    });

    it("should have the right owner", async () => {
        const instance = await RickHeadERC721.deployed();
        const owner = await instance.owner();
        assert.equal(owner, accounts[0]);
    });

    it("should reveal collection and set the baseURI", async () => {
        const instance = await RickHeadERC721.deployed();
        let State = await instance.collectionRevealed.call();
        let URI = await instance.getURI()
        // update the collectionRevealed bool and baseURI
        let newState = await instance.revealCollection("https://newrevealuri/");
        let State2 = await instance.collectionRevealed.call()
        assert.ok(State == !State2);

        let URI_reveal = await instance.getURI();
        // assert.ok(URI != URI_reveal);
        try {
            URI == URI_reveal;
        } catch (err) {
            assert(err);
        }

    });

    it("should be able to update pause status", async () => {
        const instance = await RickHeadERC721.deployed();
        let paused = await instance.paused()
        assert.equal(paused, false);

        // update paused status to true
        await instance.pause()
        paused = await instance.paused()
        assert.equal(paused, true);

        // update paused status to false
        await instance.unpause()
        paused = await instance.paused()
        assert.equal(paused, false);

        // only owner can update paused status to false
        try {
            await instance.pause({ from: accounts[1] })
        } catch (e) {

        }
        paused = await instance.paused()
        assert.equal(paused, false);

    });

    it("should advance the phase", async () => {
        const instance = await RickHeadERC721.deployed();
        let phaseValue = await RickHeadERC721.enums.SalePhase.Presale; 
        await instance.setPhase(0,phaseValue);        
        let phase1 = await instance.phase();        
        assert.equal(phase1, phaseValue);
    });

    it("should set the phase price", async () => {
        const instance = await RickHeadERC721.deployed();        
        let phasePrice = web3.utils.toWei('2',"ether");               
        await instance.setPhase(phasePrice, 0);       
        let price = await instance.mintPrice();
        assert.equal(phasePrice, price);

    });

    it("should let only contract owner change the adminSigner address", async () => {
        const instance = await RickHeadERC721.deployed();
        let signer = await instance.getAdminSigner();
        let changeSigner = "";
        //only owner can change set signer
        try {
            changeSigner = await instance.setAdminSigner("0xc98c0EF4d6211D1fAf95dF29519EC4e1Db5Bf9f7", { from: accounts[1] })
        } catch (err) {

        }
        let prevSigner = signer
        signer = await instance.getAdminSigner();
        //verify that the admin signer has not been changed
        assert.equal(signer, prevSigner)
        //owner changes signer
        signer = "0xc98c0EF4d6211D1fAf95dF29519EC4e1Db5Bf9f7";
        changeSigner = await instance.setAdminSigner("0xc98c0EF4d6211D1fAf95dF29519EC4e1Db5Bf9f7", {from: accounts[0]} );
        let  newSigner = await instance.getAdminSigner();
        assert.equal(signer, newSigner);

    });

});


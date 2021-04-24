namespace Lab5 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Extensions.Convert;

    operation SayHello() : Unit {
        Message("Hello quantum world!");
    }

    operation diagnonalBasis (qs : Qubit[]) : Unit {
        ApplyToEach(H, qs); // this applies the hadamard gate to each element of qs[]
    }

    operation putIntoSuperpos (q : Qubit) : Unit {
        //passing qubit through Hadamar Gate
        H(q);
    }

    //creating bases
    operation makeArray (size : Int) : Bool[] {

        //initializing array
        mutable array = new Bool[size];

        //populating array
        for index in 0 .. size - 1 {
            set array w/= index <- DrawRandomBool(0.5);
        }

        //returning array
        return array;
    }

    operation prepare (qs : Qubit[], bases : Bool[], bits : Bool[]) : Unit {
        // passing bits through proper gates
        let size = Length(qs);

        for index in 0 .. size - 1 {
            if(bits[index]) {
                X(qs[index]);
            }
            if(bases[index]) {
                H(qs[index]);
            }
        }
    }

    operation measure (qs : Qubit[], bases : Bool[]) : Bool[] {
        let size = Length(qs);

        for index in 0 .. size - 1 {
            if(bases[index]) {
                H(qs[index]);
            }
        }

        //converting Qubit[] to type Result[] and returning as Bool[]
        return ResultArrayAsBoolArray(MultiM(qs));
    }



    operation makeKey (hermBasis : Bool[], harryBasis : Bool[], harryBits : Bool[]) : Bool[] {
        mutable key = new Bool[0];
        let size = Length(hermBasis);

        for index in 0 .. size - 1 {
            if (hermBasis[index] == harryBasis[index]){
                set key += [harryBits[index]];
            }
        }
        return key;
    }

    operation checkMatch (hermKey : Bool[], harryKey : Bool[], percError : Int) : Bool {
        let size = Length(hermKey);
        mutable incorrect = 0;

        //adding up number of inconsistencies between the keys
        for index in 0 .. size - 1 {
            if(hermKey[index] != harryKey[index]) {
                set incorrect += 1;
            }
        }

        let acceptedRatio = IntAsDouble(percError) / 100.0;
        let trueRatio = IntAsDouble(incorrect) / IntAsDouble(size);

        if (trueRatio <= acceptedRatio){
            return true;
        }
        return false;
    }

    operation eavesdrop (qs : Qubit[]) : Unit {
        for qubit in qs {
            let randomBasis = DrawRandomBool(0.5);
            
            //Making me set an expression so I stuff it into a temp variable
            let temp = ResultAsBool(Measure([randomBasis ? PauliX | PauliZ], [qubit]));
        }
    }

    operation convertToResult(boolArray : Bool[]) : Result[]{
        let resArray = BoolArrayAsResultArray(boolArray);
        return resArray;
    }

    @EntryPoint()
    operation MainFunction() : Result[]{
        //NOTES:
        //use "let" to declare an int
        //use "use" to allocate bits
        //

        //allocating qubits
        let basisSize = 20;
        use qs = Qubit[basisSize];
        let size = Length(qs);
        let percError = 1;

        //creating Hermione's basis and bits
        Message("Creating Hermione's basis and bits...");
        let hermBasis = makeArray(size);
        let hermBits = makeArray(size);
        Message($"Hermoine's Basis: {hermBasis}\nHermione's Bits: {hermBits}");

        //creating Harry's basis
        Message("Creating Harry's Basis...");
        let harryBasis = makeArray(size);
        Message($"Harry's Basis: {harryBasis}");

        //preparing Hermione's bits with her own basis and bits
        Message("Preparing Hermione's bits with her own basis and bits...");
        prepare(qs, hermBasis, hermBits);

        //Eavesdropping from Voldemort at random
        //eavesdrop(qs);

        //Harry measuring Hermione's bits with his own basis
        Message("Measuring Hermione's bits...");
        let harryBits = measure(qs, harryBasis);

        //generating shared key
        Message("Generating shared key...");
        let hermKey = makeKey(hermBasis, harryBasis, hermBits);
        let harryKey = makeKey(hermBasis, harryBasis, harryBits);
        Message($"Hermione's Key: {hermKey}");
        Message($"Harry's Key: {harryKey}");

        //Checking keys match
        Message("Determining if keys match (detecting eavesdropper)...");
        if(checkMatch(hermKey, harryKey, percError)) { 
            //Message($"Keys Generated! {hermKey}/{harryKey}");
            Message($"Sifted Keys Are: {hermKey}");
            
        }else{
            Message("Eavesdropper detected. Throwing away keys...");
            // FOR NOW RETURNING EMPTY RESULT ARRAYS
        }
        return convertToResult(hermKey);
    }
}

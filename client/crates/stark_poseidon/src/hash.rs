use crate::{permute_comp, PoseidonState};
use stark_curve::FieldElement;

/// Hashes two elements using the Poseidon hash.
///
/// Equivalent to [`poseidon_hash`](https://github.com/starkware-libs/cairo-lang/blob/12ca9e91bbdc8a423c63280949c7e34382792067/src/starkware/cairo/common/builtin_poseidon/poseidon.cairo#L5).
pub fn poseidon_hash(x: FieldElement, y: FieldElement) -> FieldElement {
    let mut state = [x, y, FieldElement::TWO];
    permute_comp(&mut state);

    state[0]
}

/// Hashes a number of messages using the Poseidon hash.
///
/// Equivalent to [`poseidon_hash_many`](https://github.com/starkware-libs/cairo-lang/blob/12ca9e91bbdc8a423c63280949c7e34382792067/src/starkware/cairo/common/builtin_poseidon/poseidon.cairo#L28).
pub fn poseidon_hash_many(msgs: &[FieldElement]) -> FieldElement {
    let mut state = [FieldElement::ZERO, FieldElement::ZERO, FieldElement::ZERO];
    let mut iter = msgs.chunks_exact(2);

    for msg in iter.by_ref() {
        state[0] += msg[0];
        state[1] += msg[1];
        permute_comp(&mut state);
    }
    let r = iter.remainder();
    if r.len() == 1 {
        state[0] += r[0];
    }
    state[r.len()] += FieldElement::ONE;
    permute_comp(&mut state);

    state[0]
}

/// The PoseidonHasher can build up a hash by appending to state
///
/// Its output is equivalent to calling [poseidon_hash_many] with the
/// field elements.
pub struct PoseidonHasher {
    state: PoseidonState,
    buffer: Option<FieldElement>,
}

impl PoseidonHasher {
    /// Creates a new PoseidonHasher
    pub fn new() -> PoseidonHasher {
        PoseidonHasher {
            state: [FieldElement::ZERO, FieldElement::ZERO, FieldElement::ZERO],
            buffer: None,
        }
    }

    /// Absorbs message into the hash
    pub fn write(&mut self, msg: FieldElement) {
        match self.buffer.take() {
            Some(previous_message) => {
                self.state[0] += previous_message;
                self.state[1] += msg;
                permute_comp(&mut self.state);
            }
            None => {
                self.buffer = Some(msg);
            }
        }
    }

    /// Finish and return hash
    pub fn finish(mut self) -> FieldElement {
        // Apply padding
        match self.buffer.take() {
            Some(last_message) => {
                self.state[0] += last_message;
                self.state[1] += FieldElement::ONE;
            }
            None => {
                self.state[0] += FieldElement::ONE;
            }
        }
        permute_comp(&mut self.state);

        self.state[0]
    }
}

impl Default for PoseidonHasher {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::{poseidon_hash, poseidon_hash_many, PoseidonHasher};
    use stark_curve::FieldElement;
    use stark_hash::Felt;

    #[test]
    fn test_poseidon_hash() {
        // The test vector is derived by running the Python implementation with random input.
        let x =
            Felt::from_hex_str("0x23a77118133287637ebdcd9e87a1613e443df789558867f5ba91faf7a024204")
                .unwrap();
        let y =
            Felt::from_hex_str("0x259f432e6f4590b9a164106cf6a659eb4862b21fb97d43588561712e8e5216a")
                .unwrap();
        let expected_hash =
            Felt::from_hex_str("0x4be9af45b942b4b0c9f04a15e37b7f34f8109873ef7ef20e9eef8a38a3011e1")
                .unwrap();
        assert_eq!(poseidon_hash(x.into(), y.into()), expected_hash.into());
    }

    #[test]
    fn test_poseidon_hash_many_empty_input() {
        // The test vector is derived by running the Python implementation with random input.
        assert_eq!(
            poseidon_hash_many(&[]),
            Felt::from_hex_str("0x2272be0f580fd156823304800919530eaa97430e972d7213ee13f4fbf7a5dbc")
                .unwrap()
                .into()
        );
    }

    #[test]
    fn test_poseidon_hash_many_single_input() {
        // The test vector is derived by running the Python implementation with random input.
        assert_eq!(
            poseidon_hash_many(&[Felt::from_hex_str(
                "0x23a77118133287637ebdcd9e87a1613e443df789558867f5ba91faf7a024204"
            )
            .unwrap()
            .into()]),
            Felt::from_hex_str("0x7d1f569e0e898982de6515c20132703410abca88ee56100e02df737fc4bf10e")
                .unwrap()
                .into()
        );
    }

    #[test]
    fn test_poseidon_hash_many_two_inputs() {
        // The test vector is derived by running the Python implementation with random input.
        assert_eq!(
            poseidon_hash_many(&[
                Felt::from_hex_str(
                    "0x259f432e6f4590b9a164106cf6a659eb4862b21fb97d43588561712e8e5216a"
                )
                .unwrap()
                .into(),
                Felt::from_hex_str(
                    "0x5487ce1af19922ad9b8a714e61a441c12e0c8b2bad640fb19488dec4f65d4d9"
                )
                .unwrap()
                .into(),
            ]),
            Felt::from_hex_str("0x70869d36570fc0b364777c9322373fb7e15452d2282ebdb5b4f3212669f2e7")
                .unwrap()
                .into()
        );
    }

    #[test]
    fn test_sponge() {
        let expected_result = FieldElement::from(
            Felt::from_hex_str("07b8f30ac298ea12d170c0873f1fa631a18c00756c6e7d1fd273b9a239d0d413")
                .unwrap(),
        );

        // Construct messages, the first few integers
        let msgs = [
            FieldElement::ZERO,
            FieldElement::ONE,
            FieldElement::TWO,
            FieldElement::THREE,
        ];

        // Construct hash from hasher
        let mut hasher = PoseidonHasher::new();
        for msg in msgs {
            hasher.write(msg);
        }
        let hasher_result = hasher.finish();

        // Construct hash from hash function
        let hash_result = poseidon_hash_many(&msgs);

        // Check they are equal
        assert_eq!(hasher_result, hash_result);
        assert_eq!(expected_result, hash_result);
    }
}

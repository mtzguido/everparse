#ifndef __BENCH_ARRAY_COMMON
#define __BENCH_ARRAY_COMMON 1

#define N 10000
#define BSIZE (30 + 3*N + (N*N)) /* size of buffer */

BenchArray_vercdl_map_pretty build() {
    float f;

    BenchArray_vercdl_submap_pretty *submaps =
      (BenchArray_vercdl_submap_pretty *)
      malloc(N * sizeof submaps[0]);
    for (int i = 0; i < N; i++) {
        uint64_t *elems = (uint64_t*) malloc(N * sizeof elems[0]);
        for (int i = 0; i < N; i++)
            elems[i] = 0;

        BenchArray_vercdl_submap_pretty submap = {
                    .tag = BenchArray_Mkvercdl_submap_pretty0,
                    .case_Mkvercdl_submap_pretty0 = {
                                .elt = elems,
                                .len = N,
                                }
        };
        submaps[i] = submap;
    }

    BenchArray_vercdl_map_pretty m = {
                .tag = BenchArray_Mkvercdl_map_pretty0,
                .case_Mkvercdl_map_pretty0 = {
                             .elt = submaps,
                             .len = N,
                             }
    };
    return m;
}


// Read the actual numbers out of a validated array
bool parse_vercdl(BenchArray_vercdl_map_pretty m)
{
    assert (m.tag == BenchArray_Mkvercdl_map_pretty1);
    CDDL_Pulse_Parse_ArrayGroup_array_iterator_t__CBOR_Pulse_API_Det_Type_cbor_det_array_iterator_t_BenchArray_aux_env4_type_1_pretty
      it = m.case_Mkvercdl_map_pretty1;

    for (int i = 0; i < N; i++) {
        BenchArray_vercdl_submap_pretty submap = BenchArray_next_iterate_array_aux_env4_type_1(&it);
        assert (submap.tag == BenchArray_Mkvercdl_submap_pretty1);
        CDDL_Pulse_Parse_ArrayGroup_array_iterator_t__CBOR_Pulse_API_Det_Type_cbor_det_array_iterator_t_BenchArray_aux_env3_type_1_pretty
          it2 = submap.case_Mkvercdl_submap_pretty1;
        for (int j = 0; j < N; j++) {
            BenchArray_vercdl_uint_pretty t = BenchArray_next_iterate_array_aux_env3_type_1(&it2);
            assert (t == 0);
        }
    }

    return true;
}
#endif

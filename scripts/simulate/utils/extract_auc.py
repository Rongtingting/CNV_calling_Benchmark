

import os

def extract_auc(dat_dir):
    all_res = []

    dat_items = os.listdir(dat_dir)
    for denoise in ("eval_denoise", "eval_nodenoise"):
        if denoise not in dat_items:
            continue
        denoise_dir = os.path.join(dat_dir, denoise)

        denoise_items = os.listdir(denoise_dir)
        for scale in ("gene_scale", "arm_scale"):
            if scale not in denoise_items:
                continue
            scale_dir = os.path.join(denoise_dir, scale)

            scale_items = os.listdir(scale_dir)
            for cnv in ("copy_gain", "copy_loss", "loh"):
                if cnv not in scale_items:
                    continue
                cnv_dir = os.path.join(scale_dir, cnv)

                cnv_items = os.listdir(cnv_dir)
                if "result" not in cnv_items:
                    continue
                res_dir = os.path.join(cnv_dir, "result")

                res_items = os.listdir(res_dir)
                for auc in ("s5_roc", "s6_prc"):
                    if auc not in res_items:
                        continue
                    auc_dir = os.path.join(res_dir, auc)

                    auc_items = os.listdir(auc_dir)
                    all_auc_fn = [fn for fn in auc_items if fn.endswith("auc.df.tsv")]
                    if len(all_auc_fn) != 1:
                        continue
                    auc_fn = os.path.join(auc_dir, all_auc_fn[0])
                    
                    with open(auc_fn, "r") as fp:
                        for line in fp:
                            items = line.strip().split("\t")
                            if items[0] in ("numbat", "xclone"):
                                all_res.append({
                                    "denoise":denoise,
                                    "scale":scale,
                                    "cnv":cnv,
                                    "auc":auc,
                                    "tool":items[0],
                                    "value":items[-1]
                                })

    return(all_res)


if __name__ == "__main__":
    dat = [
        ("allele_loss(del_prob1.0)", "/groups/cgsd/xianjie/result/xclbm/GX109/GX109_simu_230508/allele_loss/del_prob1.0"),
        ("ds_coverage(keep10perc)", "/groups/cgsd/xianjie/result/xclbm/GX109/GX109_simu_230508/ds_coverage/keep10perc"),
        ("ds_reference(keep32)", "/groups/cgsd/xianjie/result/xclbm/GX109/GX109_simu_230508/ds_normal/keep32"),
        ("ds_reference(keep10)", "/groups/cgsd/xianjie/result/xclbm/GX109/GX109_simu_230508/ds_normal/keep10"),
        ("ds_reference(keep5)", "/groups/cgsd/xianjie/result/xclbm/GX109/GX109_simu_230508/ds_normal/keep5"),
        ("ds_tumor(keep22)", "/groups/cgsd/xianjie/result/xclbm/GX109/GX109_simu_230508/ds_tumor/keep22"),
        ("ds_tumor(keep10)", "/groups/cgsd/xianjie/result/xclbm/GX109/GX109_simu_230508/ds_tumor/keep10"),
        ("ds_tumor(keep5)", "/groups/cgsd/xianjie/result/xclbm/GX109/GX109_simu_230508/ds_tumor/keep5")
    ]

    with open("simulation_auc.tsv", "w") as fp:
        for label, dat_dir in dat:
            print(label)
            res = extract_auc(dat_dir)
            for items in res:
                s = "\t".join([
                    label,
                    items["denoise"],
                    items["scale"],
                    items["cnv"],
                    items["auc"],
                    items["tool"],
                    items["value"]
                ]) + "\n"
                fp.write(s)

    print("All Done!")


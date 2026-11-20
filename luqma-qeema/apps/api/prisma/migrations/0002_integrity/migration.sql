-- 0002_integrity — قيود السلامة المالية والمخزنية على مستوى قاعدة البيانات
-- المتطلبات: ACC-16 وACC-17 وACC-13 وDB-03 وDB-10 وINV-03 وAC-05
-- القاعدة: هذه القيود تُطبَّق حتى على SQL المباشر، لا على التطبيق وحده.

-- ───── 1) قيود CHECK ─────
ALTER TABLE "journal_lines"
  ADD CONSTRAINT jl_non_negative CHECK ("debit" >= 0 AND "credit" >= 0),
  ADD CONSTRAINT jl_one_side    CHECK (("debit" > 0) <> ("credit" > 0));

ALTER TABLE "order_lines"
  ADD CONSTRAINT ol_qty_positive  CHECK ("quantity" > 0),
  ADD CONSTRAINT ol_amounts_ok    CHECK ("unitPrice" >= 0 AND "discount" >= 0 AND "vatAmount" >= 0 AND "lineTotal" >= 0),
  ADD CONSTRAINT ol_vat_rate_ok   CHECK ("vatRate" >= 0 AND "vatRate" < 1);

ALTER TABLE "orders"
  ADD CONSTRAINT o_amounts_ok CHECK ("itemsSubtotal" >= 0 AND "discountTotal" >= 0 AND "deliveryFee" >= 0 AND "vatTotal" >= 0 AND "grandTotal" >= 0);

ALTER TABLE "stock_balances"
  ADD CONSTRAINT sb_non_negative CHECK ("onHand" >= 0 AND "reserved" >= 0 AND "damaged" >= 0 AND "inTransit" >= 0),
  ADD CONSTRAINT sb_reserved_le_onhand CHECK ("reserved" <= "onHand");   -- AC-01: لا رصيد سالب ولا حجز فوق المتاح

ALTER TABLE "stock_reservations" ADD CONSTRAINT sr_qty_positive CHECK ("quantity" > 0);
ALTER TABLE "stock_movements"    ADD CONSTRAINT sm_qty_nonzero  CHECK ("quantity" <> 0);
ALTER TABLE "payments"           ADD CONSTRAINT p_amount_positive CHECK ("amount" > 0);
ALTER TABLE "refunds"            ADD CONSTRAINT r_amount_positive CHECK ("amount" > 0);
ALTER TABLE "order_ratings"      ADD CONSTRAINT rt_stars CHECK ("stars" BETWEEN 1 AND 5);
ALTER TABLE "tax_rates"          ADD CONSTRAINT tr_rate CHECK ("rate" >= 0 AND "rate" < 1);
ALTER TABLE "fiscal_periods"     ADD CONSTRAINT fp_month CHECK ("month" BETWEEN 1 AND 12);
ALTER TABLE "recipe_lines"       ADD CONSTRAINT rl_qty CHECK ("quantity" > 0 AND "wastePct" >= 0 AND "wastePct" < 100);
ALTER TABLE "modifier_groups"    ADD CONSTRAINT mg_select CHECK ("minSelect" >= 0 AND "maxSelect" >= "minSelect");

-- ───── 2) مفاتيح خارجية إضافية (DB-03) لعلاقات لم تُعرَّف كعلاقات في Prisma ─────
ALTER TABLE "payments"            ADD CONSTRAINT fk_pay_order    FOREIGN KEY ("orderId")    REFERENCES "orders"("id");
ALTER TABLE "refunds"             ADD CONSTRAINT fk_ref_payment  FOREIGN KEY ("paymentId")  REFERENCES "payments"("id");
ALTER TABLE "invoices"            ADD CONSTRAINT fk_inv_order    FOREIGN KEY ("orderId")    REFERENCES "orders"("id");
ALTER TABLE "invoices"            ADD CONSTRAINT fk_inv_branch   FOREIGN KEY ("branchId")   REFERENCES "branches"("id");
ALTER TABLE "invoices"            ADD CONSTRAINT fk_inv_original FOREIGN KEY ("originalInvoiceId") REFERENCES "invoices"("id");
ALTER TABLE "orders"              ADD CONSTRAINT fk_ord_branch   FOREIGN KEY ("branchId")   REFERENCES "branches"("id");
ALTER TABLE "orders"              ADD CONSTRAINT fk_ord_customer FOREIGN KEY ("customerId") REFERENCES "customers"("id");
ALTER TABLE "orders"              ADD CONSTRAINT fk_ord_address  FOREIGN KEY ("addressId")  REFERENCES "customer_addresses"("id");
ALTER TABLE "order_lines"         ADD CONSTRAINT fk_ol_size      FOREIGN KEY ("menuItemSizeId") REFERENCES "menu_item_sizes"("id");
ALTER TABLE "order_line_modifiers" ADD CONSTRAINT fk_olm_mod     FOREIGN KEY ("modifierId") REFERENCES "modifiers"("id");
ALTER TABLE "stock_balances"      ADD CONSTRAINT fk_sb_item      FOREIGN KEY ("itemId")      REFERENCES "items"("id");
ALTER TABLE "stock_balances"      ADD CONSTRAINT fk_sb_wh        FOREIGN KEY ("warehouseId") REFERENCES "warehouses"("id");
ALTER TABLE "stock_movements"     ADD CONSTRAINT fk_sm_item      FOREIGN KEY ("itemId")      REFERENCES "items"("id");
ALTER TABLE "stock_movements"     ADD CONSTRAINT fk_sm_wh        FOREIGN KEY ("warehouseId") REFERENCES "warehouses"("id");
ALTER TABLE "stock_movements"     ADD CONSTRAINT fk_sm_lot       FOREIGN KEY ("lotId")       REFERENCES "stock_lots"("id");
ALTER TABLE "stock_reservations"  ADD CONSTRAINT fk_sr_order     FOREIGN KEY ("orderId")     REFERENCES "orders"("id");
ALTER TABLE "stock_reservations"  ADD CONSTRAINT fk_sr_item      FOREIGN KEY ("itemId")      REFERENCES "items"("id");
ALTER TABLE "stock_lots"          ADD CONSTRAINT fk_sl_item      FOREIGN KEY ("itemId")      REFERENCES "items"("id");
ALTER TABLE "recipes"             ADD CONSTRAINT fk_rec_item     FOREIGN KEY ("outputItemId") REFERENCES "items"("id");
ALTER TABLE "recipe_lines"        ADD CONSTRAINT fk_rl_item      FOREIGN KEY ("itemId")      REFERENCES "items"("id");
ALTER TABLE "menu_items"          ADD CONSTRAINT fk_mi_item      FOREIGN KEY ("itemId")      REFERENCES "items"("id");
ALTER TABLE "menu_item_sizes"     ADD CONSTRAINT fk_mis_recipe   FOREIGN KEY ("recipeId")    REFERENCES "recipes"("id");
ALTER TABLE "items"               ADD CONSTRAINT fk_item_unit    FOREIGN KEY ("baseUnitId")  REFERENCES "units"("id");
ALTER TABLE "items"               ADD CONSTRAINT fk_item_tax     FOREIGN KEY ("taxRateId")   REFERENCES "tax_rates"("id");
ALTER TABLE "journal_entries"     ADD CONSTRAINT fk_je_period    FOREIGN KEY ("periodId")    REFERENCES "fiscal_periods"("id");
ALTER TABLE "journal_entries"     ADD CONSTRAINT fk_je_reverses  FOREIGN KEY ("reversesId")  REFERENCES "journal_entries"("id");
ALTER TABLE "journal_lines"       ADD CONSTRAINT fk_jl_cc        FOREIGN KEY ("costCenterId") REFERENCES "cost_centers"("id");
ALTER TABLE "coupon_redemptions"  ADD CONSTRAINT fk_cr_order     FOREIGN KEY ("orderId")     REFERENCES "orders"("id");
ALTER TABLE "delivery_assignments" ADD CONSTRAINT fk_da_order    FOREIGN KEY ("orderId")     REFERENCES "orders"("id");
ALTER TABLE "delivery_assignments" ADD CONSTRAINT fk_da_courier  FOREIGN KEY ("courierId")   REFERENCES "couriers"("id");
ALTER TABLE "kitchen_tickets"     ADD CONSTRAINT fk_kt_order     FOREIGN KEY ("orderId")     REFERENCES "orders"("id");
ALTER TABLE "pos_shifts"          ADD CONSTRAINT fk_ps_terminal  FOREIGN KEY ("terminalId")  REFERENCES "pos_terminals"("id");
ALTER TABLE "orders"              ADD CONSTRAINT fk_ord_shift    FOREIGN KEY ("posShiftId")  REFERENCES "pos_shifts"("id");

-- ───── 3) توازن القيد عند الترحيل (ACC-16، AC-05) — قيد مؤجل يُفحص عند الإيداع ─────
CREATE OR REPLACE FUNCTION lq_check_entry_balanced() RETURNS trigger AS $$
DECLARE e_id uuid; e_status text; d numeric; c numeric; n int;
BEGIN
  IF TG_TABLE_NAME = 'journal_entries' THEN
    e_id := NEW."id";
  ELSIF TG_OP = 'DELETE' THEN
    e_id := OLD."entryId";
  ELSE
    e_id := NEW."entryId";
  END IF;
  SELECT "status"::text INTO e_status FROM "journal_entries" WHERE "id" = e_id;
  IF e_status = 'POSTED' THEN
    SELECT COALESCE(SUM("debit"),0), COALESCE(SUM("credit"),0), COUNT(*) INTO d, c, n
      FROM "journal_lines" WHERE "entryId" = e_id;
    IF n < 2 OR d <> c OR d = 0 THEN
      RAISE EXCEPTION 'LQ-ACC-16: unbalanced journal entry % (debit %, credit %, lines %)', e_id, d, c, n;
    END IF;
  END IF;
  RETURN NULL;
END $$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_je_balanced AFTER INSERT OR UPDATE ON "journal_entries"
  DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION lq_check_entry_balanced();
CREATE CONSTRAINT TRIGGER trg_jl_balanced AFTER INSERT OR UPDATE OR DELETE ON "journal_lines"
  DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION lq_check_entry_balanced();

-- ───── 4) منع تعديل أو حذف المرحّل (ACC-17، DB-10) ─────
CREATE OR REPLACE FUNCTION lq_protect_posted_entry() RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'DELETE' AND OLD."status" = 'POSTED' THEN
    RAISE EXCEPTION 'LQ-ACC-17: posted journal entry % cannot be deleted; post a reversal', OLD."id";
  END IF;
  IF TG_OP = 'UPDATE' AND OLD."status" = 'POSTED' THEN
    RAISE EXCEPTION 'LQ-ACC-17: posted journal entry % cannot be modified; post a reversal', OLD."id";
  END IF;
  RETURN COALESCE(NEW, OLD);
END $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_je_protect BEFORE UPDATE OR DELETE ON "journal_entries"
  FOR EACH ROW EXECUTE FUNCTION lq_protect_posted_entry();

CREATE OR REPLACE FUNCTION lq_protect_posted_lines() RETURNS trigger AS $$
DECLARE s text;
BEGIN
  SELECT "status"::text INTO s FROM "journal_entries" WHERE "id" = COALESCE(NEW."entryId", OLD."entryId");
  IF s = 'POSTED' THEN
    RAISE EXCEPTION 'LQ-ACC-17: lines of a posted journal entry cannot be changed';
  END IF;
  RETURN COALESCE(NEW, OLD);
END $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_jl_protect BEFORE INSERT OR UPDATE OR DELETE ON "journal_lines"
  FOR EACH ROW EXECUTE FUNCTION lq_protect_posted_lines();

-- ───── 5) لا ترحيل في فترة مقفلة (ACC-13) ─────
CREATE OR REPLACE FUNCTION lq_block_closed_period() RETURNS trigger AS $$
DECLARE closed timestamptz;
BEGIN
  SELECT "closedAt" INTO closed FROM "fiscal_periods" WHERE "id" = NEW."periodId";
  IF closed IS NOT NULL THEN
    RAISE EXCEPTION 'LQ-ACC-13: fiscal period is closed';
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_je_closed_period BEFORE INSERT ON "journal_entries"
  FOR EACH ROW EXECUTE FUNCTION lq_block_closed_period();

-- ───── 6) سجلات للإلحاق فقط: الحركات المخزنية، والتدقيق، وسجل الحالات، والفواتير (INV-03، DB-08، ORD-02) ─────
CREATE OR REPLACE FUNCTION lq_append_only() RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'LQ-APPEND-ONLY: % rows cannot be % ', TG_TABLE_NAME, lower(TG_OP);
END $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_sm_append_only  BEFORE UPDATE OR DELETE ON "stock_movements"      FOR EACH ROW EXECUTE FUNCTION lq_append_only();
CREATE TRIGGER trg_al_append_only  BEFORE UPDATE OR DELETE ON "audit_logs"           FOR EACH ROW EXECUTE FUNCTION lq_append_only();
CREATE TRIGGER trg_osh_append_only BEFORE UPDATE OR DELETE ON "order_status_history" FOR EACH ROW EXECUTE FUNCTION lq_append_only();
CREATE TRIGGER trg_il_append_only  BEFORE UPDATE OR DELETE ON "invoice_lines"        FOR EACH ROW EXECUTE FUNCTION lq_append_only();

-- الفاتورة: لا حذف؛ والتعديل مسموح لحالة الإرسال إلى «فاتورة» فقط
CREATE OR REPLACE FUNCTION lq_protect_invoice() RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN RAISE EXCEPTION 'LQ-INVOICE: invoices cannot be deleted; issue a credit note'; END IF;
  IF (to_jsonb(NEW) - 'zatcaStatus') <> (to_jsonb(OLD) - 'zatcaStatus') THEN
    RAISE EXCEPTION 'LQ-INVOICE: issued invoice % cannot be modified', OLD."number";
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_inv_protect BEFORE UPDATE OR DELETE ON "invoices" FOR EACH ROW EXECUTE FUNCTION lq_protect_invoice();

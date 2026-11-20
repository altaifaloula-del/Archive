-- CreateEnum
CREATE TYPE "ItemType" AS ENUM ('RAW', 'SEMI_FINISHED', 'MEAL', 'RETAIL');

-- CreateEnum
CREATE TYPE "OrderStatus" AS ENUM ('RECEIVED', 'AWAITING_CONFIRMATION', 'CONFIRMED', 'PREPARING', 'READY', 'COURIER_ASSIGNED', 'PICKED_UP', 'ON_THE_WAY', 'DELIVERED', 'DELIVERY_FAILED', 'CANCELLED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "OrderType" AS ENUM ('DELIVERY', 'PICKUP', 'TAKEAWAY', 'DINE_IN');

-- CreateEnum
CREATE TYPE "Channel" AS ENUM ('APP', 'POS', 'WEB', 'AGGREGATOR');

-- CreateEnum
CREATE TYPE "StockMovementType" AS ENUM ('PURCHASE_RECEIPT', 'SALE_CONSUMPTION', 'PRODUCTION_IN', 'PRODUCTION_OUT', 'WASTE', 'ADJUSTMENT', 'TRANSFER_IN', 'TRANSFER_OUT', 'RETURN_TO_SUPPLIER', 'CUSTOMER_RETURN');

-- CreateEnum
CREATE TYPE "DocumentStatus" AS ENUM ('DRAFT', 'APPROVED', 'POSTED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('CASH', 'MADA', 'CARD', 'APPLE_PAY', 'STC_PAY', 'CASH_ON_DELIVERY', 'LOYALTY_POINTS');

-- CreateEnum
CREATE TYPE "AccountType" AS ENUM ('ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE');

-- CreateEnum
CREATE TYPE "InvoiceKind" AS ENUM ('SIMPLIFIED_TAX_INVOICE', 'TAX_INVOICE', 'CREDIT_NOTE', 'DEBIT_NOTE');

-- CreateTable
CREATE TABLE "companies" (
    "id" UUID NOT NULL,
    "legalNameAr" TEXT NOT NULL,
    "legalNameEn" TEXT,
    "crNumber" TEXT,
    "vatNumber" TEXT,
    "nationalAddr" TEXT,
    "currency" CHAR(3) NOT NULL DEFAULT 'SAR',
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "companies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branches" (
    "id" UUID NOT NULL,
    "companyId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "nameAr" TEXT NOT NULL,
    "nameEn" TEXT,
    "address" TEXT,
    "latitude" DECIMAL(9,6),
    "longitude" DECIMAL(9,6),
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "acceptingOrders" BOOLEAN NOT NULL DEFAULT true,
    "pausedUntil" TIMESTAMPTZ,
    "pauseReason" TEXT,
    "maxOpenOrders" INTEGER,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "branches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branch_hours" (
    "id" UUID NOT NULL,
    "branchId" UUID NOT NULL,
    "channel" "Channel",
    "weekday" INTEGER NOT NULL,
    "opensAt" TEXT NOT NULL,
    "closesAt" TEXT NOT NULL,

    CONSTRAINT "branch_hours_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "warehouses" (
    "id" UUID NOT NULL,
    "branchId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "nameAr" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "warehouses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tax_rates" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "nameAr" TEXT NOT NULL,
    "rate" DECIMAL(5,4) NOT NULL,
    "validFrom" TIMESTAMPTZ NOT NULL,
    "validTo" TIMESTAMPTZ,

    CONSTRAINT "tax_rates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "document_sequences" (
    "id" UUID NOT NULL,
    "docType" TEXT NOT NULL,
    "branchId" UUID NOT NULL,
    "year" INTEGER NOT NULL,
    "prefix" TEXT NOT NULL,
    "nextValue" BIGINT NOT NULL DEFAULT 1,

    CONSTRAINT "document_sequences_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "phone" TEXT NOT NULL,
    "email" TEXT,
    "fullName" TEXT NOT NULL,
    "passwordHash" TEXT,
    "mfaSecret" TEXT,
    "mfaEnabled" BOOLEAN NOT NULL DEFAULT false,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "lastLoginAt" TIMESTAMPTZ,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,
    "deletedAt" TIMESTAMPTZ,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "roles" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "nameAr" TEXT NOT NULL,

    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "permissions" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "nameAr" TEXT NOT NULL,

    CONSTRAINT "permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "role_permissions" (
    "roleId" UUID NOT NULL,
    "permissionId" UUID NOT NULL,

    CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("roleId","permissionId")
);

-- CreateTable
CREATE TABLE "user_roles" (
    "userId" UUID NOT NULL,
    "roleId" UUID NOT NULL,
    "branchId" UUID,

    CONSTRAINT "user_roles_pkey" PRIMARY KEY ("userId","roleId")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "device" TEXT,
    "expiresAt" TIMESTAMPTZ NOT NULL,
    "revokedAt" TIMESTAMPTZ,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "units" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "nameAr" TEXT NOT NULL,

    CONSTRAINT "units_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "items" (
    "id" UUID NOT NULL,
    "sku" TEXT NOT NULL,
    "type" "ItemType" NOT NULL,
    "nameAr" TEXT NOT NULL,
    "nameEn" TEXT,
    "baseUnitId" UUID NOT NULL,
    "taxRateId" UUID,
    "categoryId" UUID,
    "trackLots" BOOLEAN NOT NULL DEFAULT false,
    "reorderLevel" DECIMAL(14,4),
    "standardCost" DECIMAL(14,4),
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,
    "deletedAt" TIMESTAMPTZ,

    CONSTRAINT "items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "unit_conversions" (
    "id" UUID NOT NULL,
    "itemId" UUID NOT NULL,
    "unitId" UUID NOT NULL,
    "factor" DECIMAL(14,6) NOT NULL,
    "purpose" TEXT NOT NULL,

    CONSTRAINT "unit_conversions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "item_barcodes" (
    "id" UUID NOT NULL,
    "itemId" UUID NOT NULL,
    "barcode" TEXT NOT NULL,

    CONSTRAINT "item_barcodes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "item_categories" (
    "id" UUID NOT NULL,
    "parentId" UUID,
    "nameAr" TEXT NOT NULL,

    CONSTRAINT "item_categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "menu_categories" (
    "id" UUID NOT NULL,
    "nameAr" TEXT NOT NULL,
    "nameEn" TEXT,
    "imageKey" TEXT,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "menu_categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "menu_items" (
    "id" UUID NOT NULL,
    "itemId" UUID NOT NULL,
    "categoryId" UUID NOT NULL,
    "descriptionAr" TEXT,
    "descriptionEn" TEXT,
    "imageKey" TEXT,
    "calories" INTEGER,
    "prepMinutes" INTEGER,
    "isAvailable" BOOLEAN NOT NULL DEFAULT true,
    "unavailableReason" TEXT,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "menu_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "menu_item_sizes" (
    "id" UUID NOT NULL,
    "menuItemId" UUID NOT NULL,
    "nameAr" TEXT NOT NULL,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "recipeId" UUID,

    CONSTRAINT "menu_item_sizes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "modifier_groups" (
    "id" UUID NOT NULL,
    "nameAr" TEXT NOT NULL,
    "minSelect" INTEGER NOT NULL DEFAULT 0,
    "maxSelect" INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT "modifier_groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "modifiers" (
    "id" UUID NOT NULL,
    "groupId" UUID NOT NULL,
    "nameAr" TEXT NOT NULL,
    "isRemoval" BOOLEAN NOT NULL DEFAULT false,
    "itemId" UUID,
    "quantity" DECIMAL(14,4),
    "isAvailable" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "modifiers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "menu_item_modifier_groups" (
    "menuItemId" UUID NOT NULL,
    "groupId" UUID NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "menu_item_modifier_groups_pkey" PRIMARY KEY ("menuItemId","groupId")
);

-- CreateTable
CREATE TABLE "allergens" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "nameAr" TEXT NOT NULL,

    CONSTRAINT "allergens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "menu_item_allergens" (
    "menuItemId" UUID NOT NULL,
    "allergenId" UUID NOT NULL,

    CONSTRAINT "menu_item_allergens_pkey" PRIMARY KEY ("menuItemId","allergenId")
);

-- CreateTable
CREATE TABLE "recipes" (
    "id" UUID NOT NULL,
    "outputItemId" UUID NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "yieldQty" DECIMAL(14,4) NOT NULL,
    "approvedById" UUID,
    "approvedAt" TIMESTAMPTZ,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "recipes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "recipe_lines" (
    "id" UUID NOT NULL,
    "recipeId" UUID NOT NULL,
    "itemId" UUID NOT NULL,
    "quantity" DECIMAL(14,4) NOT NULL,
    "wastePct" DECIMAL(5,2) NOT NULL DEFAULT 0,

    CONSTRAINT "recipe_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "production_batches" (
    "id" UUID NOT NULL,
    "number" TEXT NOT NULL,
    "warehouseId" UUID NOT NULL,
    "recipeId" UUID NOT NULL,
    "quantity" DECIMAL(14,4) NOT NULL,
    "expiresAt" TIMESTAMPTZ,
    "producedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "producedById" UUID NOT NULL,

    CONSTRAINT "production_batches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "waste_records" (
    "id" UUID NOT NULL,
    "number" TEXT NOT NULL,
    "warehouseId" UUID NOT NULL,
    "itemId" UUID NOT NULL,
    "quantity" DECIMAL(14,4) NOT NULL,
    "reason" TEXT NOT NULL,
    "unitCost" DECIMAL(14,4) NOT NULL,
    "recordedById" UUID NOT NULL,
    "approvedById" UUID,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "waste_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "price_lists" (
    "id" UUID NOT NULL,
    "nameAr" TEXT NOT NULL,
    "branchId" UUID,
    "channel" "Channel",
    "validFrom" TIMESTAMPTZ NOT NULL,
    "validTo" TIMESTAMPTZ,
    "pricesIncludeVat" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "price_lists_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "price_list_items" (
    "id" UUID NOT NULL,
    "priceListId" UUID NOT NULL,
    "menuItemSizeId" UUID,
    "modifierId" UUID,
    "price" DECIMAL(14,2) NOT NULL,

    CONSTRAINT "price_list_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "promotions" (
    "id" UUID NOT NULL,
    "nameAr" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "value" DECIMAL(14,2),
    "rules" JSONB NOT NULL,
    "validFrom" TIMESTAMPTZ NOT NULL,
    "validTo" TIMESTAMPTZ NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "promotions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "coupons" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "promotionId" UUID NOT NULL,
    "maxRedemptions" INTEGER,
    "perCustomerLimit" INTEGER DEFAULT 1,
    "validFrom" TIMESTAMPTZ NOT NULL,
    "validTo" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "coupons_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "coupon_redemptions" (
    "id" UUID NOT NULL,
    "couponId" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "customerId" UUID NOT NULL,
    "amount" DECIMAL(14,2) NOT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "coupon_redemptions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_lots" (
    "id" UUID NOT NULL,
    "itemId" UUID NOT NULL,
    "warehouseId" UUID NOT NULL,
    "lotNumber" TEXT NOT NULL,
    "expiresAt" TIMESTAMPTZ,
    "unitCost" DECIMAL(14,4) NOT NULL,
    "receivedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stock_lots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_balances" (
    "itemId" UUID NOT NULL,
    "warehouseId" UUID NOT NULL,
    "onHand" DECIMAL(14,4) NOT NULL DEFAULT 0,
    "reserved" DECIMAL(14,4) NOT NULL DEFAULT 0,
    "damaged" DECIMAL(14,4) NOT NULL DEFAULT 0,
    "inTransit" DECIMAL(14,4) NOT NULL DEFAULT 0,
    "avgCost" DECIMAL(14,4) NOT NULL DEFAULT 0,

    CONSTRAINT "stock_balances_pkey" PRIMARY KEY ("itemId","warehouseId")
);

-- CreateTable
CREATE TABLE "stock_movements" (
    "id" UUID NOT NULL,
    "itemId" UUID NOT NULL,
    "warehouseId" UUID NOT NULL,
    "lotId" UUID,
    "type" "StockMovementType" NOT NULL,
    "quantity" DECIMAL(14,4) NOT NULL,
    "unitCost" DECIMAL(14,4) NOT NULL,
    "sourceType" TEXT NOT NULL,
    "sourceId" UUID NOT NULL,
    "createdById" UUID,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stock_movements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_reservations" (
    "id" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "itemId" UUID NOT NULL,
    "warehouseId" UUID NOT NULL,
    "quantity" DECIMAL(14,4) NOT NULL,
    "expiresAt" TIMESTAMPTZ NOT NULL,
    "releasedAt" TIMESTAMPTZ,
    "consumedAt" TIMESTAMPTZ,

    CONSTRAINT "stock_reservations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_counts" (
    "id" UUID NOT NULL,
    "number" TEXT NOT NULL,
    "warehouseId" UUID NOT NULL,
    "kind" TEXT NOT NULL,
    "status" "DocumentStatus" NOT NULL DEFAULT 'DRAFT',
    "countedAt" TIMESTAMPTZ NOT NULL,
    "approvedById" UUID,

    CONSTRAINT "stock_counts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_count_lines" (
    "id" UUID NOT NULL,
    "countId" UUID NOT NULL,
    "itemId" UUID NOT NULL,
    "systemQty" DECIMAL(14,4) NOT NULL,
    "countedQty" DECIMAL(14,4) NOT NULL,

    CONSTRAINT "stock_count_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "suppliers" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "nameAr" TEXT NOT NULL,
    "vatNumber" TEXT,
    "phone" TEXT,
    "paymentTermsDays" INTEGER NOT NULL DEFAULT 0,
    "accountId" UUID,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "suppliers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_orders" (
    "id" UUID NOT NULL,
    "number" TEXT NOT NULL,
    "supplierId" UUID NOT NULL,
    "warehouseId" UUID NOT NULL,
    "status" "DocumentStatus" NOT NULL DEFAULT 'DRAFT',
    "orderedAt" TIMESTAMPTZ NOT NULL,
    "approvedById" UUID,

    CONSTRAINT "purchase_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_order_lines" (
    "id" UUID NOT NULL,
    "poId" UUID NOT NULL,
    "itemId" UUID NOT NULL,
    "unitId" UUID NOT NULL,
    "quantity" DECIMAL(14,4) NOT NULL,
    "unitPrice" DECIMAL(14,4) NOT NULL,

    CONSTRAINT "purchase_order_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "goods_receipts" (
    "id" UUID NOT NULL,
    "number" TEXT NOT NULL,
    "poId" UUID,
    "warehouseId" UUID NOT NULL,
    "status" "DocumentStatus" NOT NULL DEFAULT 'DRAFT',
    "receivedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "goods_receipts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "goods_receipt_lines" (
    "id" UUID NOT NULL,
    "grnId" UUID NOT NULL,
    "itemId" UUID NOT NULL,
    "quantity" DECIMAL(14,4) NOT NULL,
    "unitCost" DECIMAL(14,4) NOT NULL,
    "lotNumber" TEXT,
    "expiresAt" TIMESTAMPTZ,

    CONSTRAINT "goods_receipt_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "supplier_invoices" (
    "id" UUID NOT NULL,
    "number" TEXT NOT NULL,
    "supplierRef" TEXT NOT NULL,
    "supplierId" UUID NOT NULL,
    "grnId" UUID,
    "status" "DocumentStatus" NOT NULL DEFAULT 'DRAFT',
    "subtotal" DECIMAL(14,2) NOT NULL,
    "vatAmount" DECIMAL(14,2) NOT NULL,
    "total" DECIMAL(14,2) NOT NULL,
    "dueAt" TIMESTAMPTZ,
    "issuedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "supplier_invoices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customers" (
    "id" UUID NOT NULL,
    "phone" TEXT NOT NULL,
    "fullName" TEXT,
    "email" TEXT,
    "marketingConsent" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deletedAt" TIMESTAMPTZ,

    CONSTRAINT "customers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customer_addresses" (
    "id" UUID NOT NULL,
    "customerId" UUID NOT NULL,
    "label" TEXT NOT NULL,
    "details" TEXT NOT NULL,
    "latitude" DECIMAL(9,6) NOT NULL,
    "longitude" DECIMAL(9,6) NOT NULL,
    "notes" TEXT,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "customer_addresses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "complaints" (
    "id" UUID NOT NULL,
    "number" TEXT NOT NULL,
    "customerId" UUID NOT NULL,
    "orderId" UUID,
    "subject" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'OPEN',
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "complaints_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "loyalty_transactions" (
    "id" UUID NOT NULL,
    "customerId" UUID NOT NULL,
    "orderId" UUID,
    "points" INTEGER NOT NULL,
    "kind" TEXT NOT NULL,
    "expiresAt" TIMESTAMPTZ,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "loyalty_transactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "orders" (
    "id" UUID NOT NULL,
    "number" TEXT NOT NULL,
    "branchId" UUID NOT NULL,
    "customerId" UUID,
    "channel" "Channel" NOT NULL,
    "type" "OrderType" NOT NULL,
    "status" "OrderStatus" NOT NULL DEFAULT 'RECEIVED',
    "addressId" UUID,
    "scheduledFor" TIMESTAMPTZ,
    "notes" TEXT,
    "itemsSubtotal" DECIMAL(14,2) NOT NULL,
    "discountTotal" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "deliveryFee" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "vatTotal" DECIMAL(14,2) NOT NULL,
    "grandTotal" DECIMAL(14,2) NOT NULL,
    "idempotencyKey" TEXT NOT NULL,
    "posShiftId" UUID,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_lines" (
    "id" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "menuItemSizeId" UUID NOT NULL,
    "nameAr" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unitPrice" DECIMAL(14,2) NOT NULL,
    "discount" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "vatRate" DECIMAL(5,4) NOT NULL,
    "vatAmount" DECIMAL(14,2) NOT NULL,
    "lineTotal" DECIMAL(14,2) NOT NULL,
    "notes" TEXT,

    CONSTRAINT "order_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_line_modifiers" (
    "id" UUID NOT NULL,
    "orderLineId" UUID NOT NULL,
    "modifierId" UUID NOT NULL,
    "nameAr" TEXT NOT NULL,
    "price" DECIMAL(14,2) NOT NULL,

    CONSTRAINT "order_line_modifiers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_status_history" (
    "id" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "fromStatus" "OrderStatus",
    "toStatus" "OrderStatus" NOT NULL,
    "reason" TEXT,
    "actorId" UUID,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "order_status_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_ratings" (
    "id" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "stars" INTEGER NOT NULL,
    "comment" TEXT,
    "itemStars" JSONB,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "order_ratings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "kitchen_stations" (
    "id" UUID NOT NULL,
    "branchId" UUID NOT NULL,
    "nameAr" TEXT NOT NULL,

    CONSTRAINT "kitchen_stations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "kitchen_tickets" (
    "id" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "stationId" UUID,
    "status" TEXT NOT NULL DEFAULT 'QUEUED',
    "targetMinutes" INTEGER,
    "startedAt" TIMESTAMPTZ,
    "readyAt" TIMESTAMPTZ,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "kitchen_tickets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "delivery_zones" (
    "id" UUID NOT NULL,
    "branchId" UUID NOT NULL,
    "nameAr" TEXT NOT NULL,
    "polygon" JSONB NOT NULL,
    "fee" DECIMAL(14,2) NOT NULL,
    "minOrder" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "delivery_zones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "couriers" (
    "id" UUID NOT NULL,
    "userId" UUID,
    "providerId" UUID,
    "fullName" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "isAvailable" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "couriers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "delivery_providers" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "nameAr" TEXT NOT NULL,
    "config" JSONB,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "delivery_providers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "delivery_assignments" (
    "id" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "courierId" UUID NOT NULL,
    "assignedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "acceptedAt" TIMESTAMPTZ,
    "pickedUpAt" TIMESTAMPTZ,
    "deliveredAt" TIMESTAMPTZ,
    "failedAt" TIMESTAMPTZ,
    "failReason" TEXT,
    "proofType" TEXT,
    "proofKey" TEXT,

    CONSTRAINT "delivery_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pos_terminals" (
    "id" UUID NOT NULL,
    "branchId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "pos_terminals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pos_shifts" (
    "id" UUID NOT NULL,
    "terminalId" UUID NOT NULL,
    "cashierId" UUID NOT NULL,
    "openedAt" TIMESTAMPTZ NOT NULL,
    "openingCash" DECIMAL(14,2) NOT NULL,
    "closedAt" TIMESTAMPTZ,
    "expectedCash" DECIMAL(14,2),
    "countedCash" DECIMAL(14,2),
    "differenceReason" TEXT,
    "approvedById" UUID,

    CONSTRAINT "pos_shifts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "idempotency_keys" (
    "key" TEXT NOT NULL,
    "scope" TEXT NOT NULL,
    "responseRef" TEXT,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "idempotency_keys_pkey" PRIMARY KEY ("key")
);

-- CreateTable
CREATE TABLE "payments" (
    "id" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "method" "PaymentMethod" NOT NULL,
    "amount" DECIMAL(14,2) NOT NULL,
    "gatewayRef" TEXT,
    "status" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "refunds" (
    "id" UUID NOT NULL,
    "paymentId" UUID NOT NULL,
    "amount" DECIMAL(14,2) NOT NULL,
    "reason" TEXT NOT NULL,
    "approvedById" UUID NOT NULL,
    "gatewayRef" TEXT,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "refunds_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoices" (
    "id" UUID NOT NULL,
    "number" TEXT NOT NULL,
    "kind" "InvoiceKind" NOT NULL,
    "branchId" UUID NOT NULL,
    "orderId" UUID,
    "originalInvoiceId" UUID,
    "issuedAt" TIMESTAMPTZ NOT NULL,
    "subtotal" DECIMAL(14,2) NOT NULL,
    "vatTotal" DECIMAL(14,2) NOT NULL,
    "total" DECIMAL(14,2) NOT NULL,
    "uuid" UUID NOT NULL,
    "icv" BIGINT NOT NULL,
    "pih" TEXT NOT NULL,
    "invoiceHash" TEXT NOT NULL,
    "qrPayload" TEXT NOT NULL,
    "zatcaStatus" TEXT NOT NULL DEFAULT 'NOT_SENT',

    CONSTRAINT "invoices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice_lines" (
    "id" UUID NOT NULL,
    "invoiceId" UUID NOT NULL,
    "nameAr" TEXT NOT NULL,
    "quantity" DECIMAL(14,4) NOT NULL,
    "unitPrice" DECIMAL(14,2) NOT NULL,
    "vatRate" DECIMAL(5,4) NOT NULL,
    "vatAmount" DECIMAL(14,2) NOT NULL,
    "lineTotal" DECIMAL(14,2) NOT NULL,

    CONSTRAINT "invoice_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "accounts" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "nameAr" TEXT NOT NULL,
    "type" "AccountType" NOT NULL,
    "parentId" UUID,
    "isPosting" BOOLEAN NOT NULL DEFAULT true,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cost_centers" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "nameAr" TEXT NOT NULL,

    CONSTRAINT "cost_centers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fiscal_periods" (
    "id" UUID NOT NULL,
    "year" INTEGER NOT NULL,
    "month" INTEGER NOT NULL,
    "startsAt" TIMESTAMPTZ NOT NULL,
    "endsAt" TIMESTAMPTZ NOT NULL,
    "closedAt" TIMESTAMPTZ,
    "closedById" UUID,

    CONSTRAINT "fiscal_periods_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "journal_entries" (
    "id" UUID NOT NULL,
    "number" TEXT NOT NULL,
    "periodId" UUID NOT NULL,
    "entryDate" TIMESTAMPTZ NOT NULL,
    "description" TEXT NOT NULL,
    "status" "DocumentStatus" NOT NULL DEFAULT 'DRAFT',
    "sourceType" TEXT NOT NULL,
    "sourceId" UUID,
    "entryKind" TEXT NOT NULL,
    "reversesId" UUID,
    "postedAt" TIMESTAMPTZ,
    "postedById" UUID,

    CONSTRAINT "journal_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "journal_lines" (
    "id" UUID NOT NULL,
    "entryId" UUID NOT NULL,
    "accountId" UUID NOT NULL,
    "costCenterId" UUID,
    "branchId" UUID,
    "debit" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "credit" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "memo" TEXT,

    CONSTRAINT "journal_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outbox_events" (
    "id" UUID NOT NULL,
    "type" TEXT NOT NULL,
    "aggregateType" TEXT NOT NULL,
    "aggregateId" UUID NOT NULL,
    "payload" JSONB NOT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processedAt" TIMESTAMPTZ,
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "lastError" TEXT,

    CONSTRAINT "outbox_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" BIGSERIAL NOT NULL,
    "actorId" UUID,
    "action" TEXT NOT NULL,
    "entityType" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "before" JSONB,
    "after" JSONB,
    "ip" TEXT,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL,
    "customerId" UUID,
    "userId" UUID,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "target" TEXT,
    "readAt" TIMESTAMPTZ,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "integration_logs" (
    "id" UUID NOT NULL,
    "provider" TEXT NOT NULL,
    "operation" TEXT NOT NULL,
    "reference" TEXT,
    "status" TEXT NOT NULL,
    "attempts" INTEGER NOT NULL DEFAULT 1,
    "request" JSONB,
    "response" JSONB,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "integration_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attachments" (
    "id" UUID NOT NULL,
    "storageKey" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "sizeBytes" INTEGER NOT NULL,
    "entityType" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "attachments_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "companies_vatNumber_key" ON "companies"("vatNumber");

-- CreateIndex
CREATE UNIQUE INDEX "branches_code_key" ON "branches"("code");

-- CreateIndex
CREATE UNIQUE INDEX "branch_hours_branchId_channel_weekday_opensAt_key" ON "branch_hours"("branchId", "channel", "weekday", "opensAt");

-- CreateIndex
CREATE UNIQUE INDEX "warehouses_code_key" ON "warehouses"("code");

-- CreateIndex
CREATE UNIQUE INDEX "tax_rates_code_key" ON "tax_rates"("code");

-- CreateIndex
CREATE UNIQUE INDEX "document_sequences_docType_branchId_year_key" ON "document_sequences"("docType", "branchId", "year");

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "roles_code_key" ON "roles"("code");

-- CreateIndex
CREATE UNIQUE INDEX "permissions_code_key" ON "permissions"("code");

-- CreateIndex
CREATE UNIQUE INDEX "sessions_tokenHash_key" ON "sessions"("tokenHash");

-- CreateIndex
CREATE INDEX "sessions_userId_idx" ON "sessions"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "units_code_key" ON "units"("code");

-- CreateIndex
CREATE UNIQUE INDEX "items_sku_key" ON "items"("sku");

-- CreateIndex
CREATE INDEX "items_type_isActive_idx" ON "items"("type", "isActive");

-- CreateIndex
CREATE UNIQUE INDEX "unit_conversions_itemId_unitId_purpose_key" ON "unit_conversions"("itemId", "unitId", "purpose");

-- CreateIndex
CREATE UNIQUE INDEX "item_barcodes_barcode_key" ON "item_barcodes"("barcode");

-- CreateIndex
CREATE UNIQUE INDEX "menu_items_itemId_key" ON "menu_items"("itemId");

-- CreateIndex
CREATE INDEX "menu_items_categoryId_isAvailable_idx" ON "menu_items"("categoryId", "isAvailable");

-- CreateIndex
CREATE UNIQUE INDEX "allergens_code_key" ON "allergens"("code");

-- CreateIndex
CREATE UNIQUE INDEX "recipes_outputItemId_version_key" ON "recipes"("outputItemId", "version");

-- CreateIndex
CREATE UNIQUE INDEX "production_batches_number_key" ON "production_batches"("number");

-- CreateIndex
CREATE UNIQUE INDEX "waste_records_number_key" ON "waste_records"("number");

-- CreateIndex
CREATE UNIQUE INDEX "price_list_items_priceListId_menuItemSizeId_modifierId_key" ON "price_list_items"("priceListId", "menuItemSizeId", "modifierId");

-- CreateIndex
CREATE UNIQUE INDEX "coupons_code_key" ON "coupons"("code");

-- CreateIndex
CREATE UNIQUE INDEX "coupon_redemptions_orderId_key" ON "coupon_redemptions"("orderId");

-- CreateIndex
CREATE INDEX "stock_lots_itemId_warehouseId_expiresAt_idx" ON "stock_lots"("itemId", "warehouseId", "expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "stock_lots_itemId_warehouseId_lotNumber_key" ON "stock_lots"("itemId", "warehouseId", "lotNumber");

-- CreateIndex
CREATE INDEX "stock_movements_itemId_warehouseId_createdAt_idx" ON "stock_movements"("itemId", "warehouseId", "createdAt");

-- CreateIndex
CREATE INDEX "stock_movements_sourceType_sourceId_idx" ON "stock_movements"("sourceType", "sourceId");

-- CreateIndex
CREATE INDEX "stock_reservations_orderId_idx" ON "stock_reservations"("orderId");

-- CreateIndex
CREATE INDEX "stock_reservations_expiresAt_idx" ON "stock_reservations"("expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "stock_counts_number_key" ON "stock_counts"("number");

-- CreateIndex
CREATE UNIQUE INDEX "suppliers_code_key" ON "suppliers"("code");

-- CreateIndex
CREATE UNIQUE INDEX "purchase_orders_number_key" ON "purchase_orders"("number");

-- CreateIndex
CREATE UNIQUE INDEX "goods_receipts_number_key" ON "goods_receipts"("number");

-- CreateIndex
CREATE UNIQUE INDEX "supplier_invoices_number_key" ON "supplier_invoices"("number");

-- CreateIndex
CREATE UNIQUE INDEX "supplier_invoices_supplierId_supplierRef_key" ON "supplier_invoices"("supplierId", "supplierRef");

-- CreateIndex
CREATE UNIQUE INDEX "customers_phone_key" ON "customers"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "complaints_number_key" ON "complaints"("number");

-- CreateIndex
CREATE INDEX "loyalty_transactions_customerId_createdAt_idx" ON "loyalty_transactions"("customerId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "orders_number_key" ON "orders"("number");

-- CreateIndex
CREATE UNIQUE INDEX "orders_idempotencyKey_key" ON "orders"("idempotencyKey");

-- CreateIndex
CREATE INDEX "orders_branchId_status_createdAt_idx" ON "orders"("branchId", "status", "createdAt");

-- CreateIndex
CREATE INDEX "orders_customerId_createdAt_idx" ON "orders"("customerId", "createdAt");

-- CreateIndex
CREATE INDEX "order_status_history_orderId_createdAt_idx" ON "order_status_history"("orderId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "order_ratings_orderId_key" ON "order_ratings"("orderId");

-- CreateIndex
CREATE INDEX "kitchen_tickets_stationId_status_createdAt_idx" ON "kitchen_tickets"("stationId", "status", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "couriers_userId_key" ON "couriers"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "delivery_providers_code_key" ON "delivery_providers"("code");

-- CreateIndex
CREATE INDEX "delivery_assignments_courierId_assignedAt_idx" ON "delivery_assignments"("courierId", "assignedAt");

-- CreateIndex
CREATE INDEX "delivery_assignments_orderId_idx" ON "delivery_assignments"("orderId");

-- CreateIndex
CREATE UNIQUE INDEX "pos_terminals_code_key" ON "pos_terminals"("code");

-- CreateIndex
CREATE UNIQUE INDEX "payments_gatewayRef_key" ON "payments"("gatewayRef");

-- CreateIndex
CREATE INDEX "payments_orderId_idx" ON "payments"("orderId");

-- CreateIndex
CREATE UNIQUE INDEX "refunds_gatewayRef_key" ON "refunds"("gatewayRef");

-- CreateIndex
CREATE UNIQUE INDEX "invoices_number_key" ON "invoices"("number");

-- CreateIndex
CREATE UNIQUE INDEX "invoices_uuid_key" ON "invoices"("uuid");

-- CreateIndex
CREATE UNIQUE INDEX "invoices_branchId_icv_key" ON "invoices"("branchId", "icv");

-- CreateIndex
CREATE UNIQUE INDEX "accounts_code_key" ON "accounts"("code");

-- CreateIndex
CREATE UNIQUE INDEX "cost_centers_code_key" ON "cost_centers"("code");

-- CreateIndex
CREATE UNIQUE INDEX "fiscal_periods_year_month_key" ON "fiscal_periods"("year", "month");

-- CreateIndex
CREATE UNIQUE INDEX "journal_entries_number_key" ON "journal_entries"("number");

-- CreateIndex
CREATE UNIQUE INDEX "journal_entries_reversesId_key" ON "journal_entries"("reversesId");

-- CreateIndex
CREATE UNIQUE INDEX "journal_entries_sourceType_sourceId_entryKind_key" ON "journal_entries"("sourceType", "sourceId", "entryKind");

-- CreateIndex
CREATE INDEX "journal_lines_accountId_idx" ON "journal_lines"("accountId");

-- CreateIndex
CREATE INDEX "outbox_events_processedAt_createdAt_idx" ON "outbox_events"("processedAt", "createdAt");

-- CreateIndex
CREATE INDEX "audit_logs_entityType_entityId_idx" ON "audit_logs"("entityType", "entityId");

-- CreateIndex
CREATE INDEX "audit_logs_actorId_createdAt_idx" ON "audit_logs"("actorId", "createdAt");

-- CreateIndex
CREATE INDEX "notifications_customerId_createdAt_idx" ON "notifications"("customerId", "createdAt");

-- CreateIndex
CREATE INDEX "integration_logs_provider_status_createdAt_idx" ON "integration_logs"("provider", "status", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "attachments_storageKey_key" ON "attachments"("storageKey");

-- AddForeignKey
ALTER TABLE "branches" ADD CONSTRAINT "branches_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branch_hours" ADD CONSTRAINT "branch_hours_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "branches"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouses" ADD CONSTRAINT "warehouses_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "branches"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "permissions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "unit_conversions" ADD CONSTRAINT "unit_conversions_itemId_fkey" FOREIGN KEY ("itemId") REFERENCES "items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "item_barcodes" ADD CONSTRAINT "item_barcodes_itemId_fkey" FOREIGN KEY ("itemId") REFERENCES "items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "menu_items" ADD CONSTRAINT "menu_items_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "menu_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "menu_item_sizes" ADD CONSTRAINT "menu_item_sizes_menuItemId_fkey" FOREIGN KEY ("menuItemId") REFERENCES "menu_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "modifiers" ADD CONSTRAINT "modifiers_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "modifier_groups"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "menu_item_modifier_groups" ADD CONSTRAINT "menu_item_modifier_groups_menuItemId_fkey" FOREIGN KEY ("menuItemId") REFERENCES "menu_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "menu_item_modifier_groups" ADD CONSTRAINT "menu_item_modifier_groups_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "modifier_groups"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "menu_item_allergens" ADD CONSTRAINT "menu_item_allergens_menuItemId_fkey" FOREIGN KEY ("menuItemId") REFERENCES "menu_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "menu_item_allergens" ADD CONSTRAINT "menu_item_allergens_allergenId_fkey" FOREIGN KEY ("allergenId") REFERENCES "allergens"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "recipe_lines" ADD CONSTRAINT "recipe_lines_recipeId_fkey" FOREIGN KEY ("recipeId") REFERENCES "recipes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "price_list_items" ADD CONSTRAINT "price_list_items_priceListId_fkey" FOREIGN KEY ("priceListId") REFERENCES "price_lists"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "coupon_redemptions" ADD CONSTRAINT "coupon_redemptions_couponId_fkey" FOREIGN KEY ("couponId") REFERENCES "coupons"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_count_lines" ADD CONSTRAINT "stock_count_lines_countId_fkey" FOREIGN KEY ("countId") REFERENCES "stock_counts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_lines" ADD CONSTRAINT "purchase_order_lines_poId_fkey" FOREIGN KEY ("poId") REFERENCES "purchase_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipt_lines" ADD CONSTRAINT "goods_receipt_lines_grnId_fkey" FOREIGN KEY ("grnId") REFERENCES "goods_receipts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_addresses" ADD CONSTRAINT "customer_addresses_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "customers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_lines" ADD CONSTRAINT "order_lines_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_line_modifiers" ADD CONSTRAINT "order_line_modifiers_orderLineId_fkey" FOREIGN KEY ("orderLineId") REFERENCES "order_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_status_history" ADD CONSTRAINT "order_status_history_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_zones" ADD CONSTRAINT "delivery_zones_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "branches"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice_lines" ADD CONSTRAINT "invoice_lines_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_lines" ADD CONSTRAINT "journal_lines_entryId_fkey" FOREIGN KEY ("entryId") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_lines" ADD CONSTRAINT "journal_lines_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

